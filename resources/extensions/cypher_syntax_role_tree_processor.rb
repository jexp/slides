require 'asciidoctor/extensions' unless RUBY_ENGINE == 'opal'

include Asciidoctor

class CypherSyntaxRoleTreeProcessor < Extensions::TreeProcessor; use_dsl
  def process(document)
    document.find_by({context: :listing}) {|block| block.attr('language') == 'cypher-syntax' }.each do |block|
      block.add_role('syntax')
    end
    document
  end
end

Extensions.register do
  tree_processor CypherSyntaxRoleTreeProcessor
end
