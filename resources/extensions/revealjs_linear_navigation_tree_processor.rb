require 'asciidoctor/extensions' unless RUBY_ENGINE == 'opal'

include Asciidoctor

class RevealJsLinearNaviationTreeProcessor < Extensions::TreeProcessor; use_dsl
  def process(document)
    if document.backend == 'revealjs'
      document.find_by({context: :section}) {|section| section.level > 1 }.reverse.each do |section|
        section.parent.blocks.delete(section)
        parent_section = section.parent
        while parent_section.parent && parent_section.parent.context == :section
          parent_section = parent_section.parent
        end
        section.level = 1
        document.blocks.insert(parent_section.index + 1, section)
      end
    end
    document
  end
end

Extensions.register do
  tree_processor RevealJsLinearNaviationTreeProcessor
end
