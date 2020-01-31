# -*- coding: utf-8 -*- #
# frozen_string_literal: true
require 'rouge' unless defined? ::Rouge::Lexers

module Rouge
  module Themes
    class NeoForest < CSSTheme
      name 'neo.forest'

      style Comment::Multiline,
            Comment::Preproc,
            Comment::Single,
            Comment::Special,
            Comment,                          :fg => '#75787b'
      style Error,
            Generic::Error,
            Generic::Traceback,               :fg => '#960050'
      style Name::Function,
            Operator::Word,
            Keyword,
            Keyword::Constant,
            Keyword::Declaration,
            Keyword::Reserved,
            Name::Constant,
            Keyword::Type,                    :fg => '#859900'
      style Literal::String,                  :fg => '#b58900'
      style Literal::Number,                  :fg => '#2aa198'
      style Operator,
            Name::Namespace,
            Name::Label,
            Literal::String::Delimiter,
            Name::Property,
            Name::Entity,
            Name::Builtin::Pseudo,
            Name::Variable::Global,
            Name::Variable::Instance,
            Name::Variable,
            Text::Whitespace,
            Text,
            Name,
            Literal::String::Symbol,          :fg => '#333333'
    end
  end
end
