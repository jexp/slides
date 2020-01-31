require 'asciidoctor/extensions' unless RUBY_ENGINE == 'opal'
require 'rouge' unless defined? ::Rouge::Lexers

include Asciidoctor

module InlineHighlighter

  def self.highlight_code(lang, text, doc)
    if text.nil? || text.strip.empty?
      return ''
    end
    lexer = Rouge::Lexer.find lang
    theme = Rouge::Theme.find(doc.attr('rouge-style', 'github')).new
    formatter = if doc.backend == 'html5'
                  Rouge::Formatters::HTML.new(theme)
                else
                  Rouge::Formatters::HTMLInline.new(theme)
                end
    return formatter.format(lexer.lex(text))
  end

  class MonospacedTextInlineMacro < Extensions::InlineMacroProcessor; use_dsl
    named :monospaced_highlighter
    match %r/<code class="src-([a-z]+)">([^<]+)<\/code>/i
    positional_attributes :content

    def process(parent, target, attrs)
      raw_text = attrs[:content]
      raw_text = raw_text.gsub('&#8594;', '->') if raw_text.include? '&'
      raw_text = raw_text.gsub('&#8592;', '<-') if raw_text.include? '&'
      highlighted_text = InlineHighlighter.highlight_code(target, raw_text, parent.document)
      create_inline_pass parent, %(<code class="rouge">#{highlighted_text}</code>), attrs
    end
  end

  class SrcInlineMacro < Extensions::InlineMacroProcessor; use_dsl
    named :src
    positional_attributes :content

    def process(parent, target, attrs)
      new_text = InlineHighlighter.highlight_code(target, attrs[:content], parent.document)
      create_inline_pass parent, %(<code class="rouge">#{new_text}</code>), attrs
    end
  end
end

Extensions.register do
  inline_macro InlineHighlighter::MonospacedTextInlineMacro
  inline_macro InlineHighlighter::SrcInlineMacro
end
