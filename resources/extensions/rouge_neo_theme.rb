# -*- coding: utf-8 -*- #
# frozen_string_literal: true
require 'rouge' unless defined? ::Rouge::Lexers

module Rouge
  module Themes
    class Neo < CSSTheme
      name 'neo'

      style Comment::Multiline,
            Comment::Preproc,
            Comment::Single,
            Comment::Special,
            Comment,                          :fg => '#75787b'
      style Error,
            Generic::Error,
            Generic::Traceback,               :fg => '#960050'
      style Keyword::Constant,
            Keyword::Declaration,
            Keyword::Reserved,
            Name::Constant,
            Keyword::Type,                    :fg => '#1d75b3'
      style Literal::String,                  :fg => '#b35e14'
      style Name::Function,
            Operator,                         :fg => '#2e383c'
      style Name::Namespace,
            Name::Label,
            Literal::String::Delimiter,
            Name::Property,                   :fg => '#75438a'
      style Name::Entity,
            Name::Builtin::Pseudo,
            Name::Variable::Global,
            Name::Variable::Instance,
            Name::Variable,
            Text::Whitespace,
            Text,
            Name,                             :fg => '#047d65'
      style Keyword,                          :fg => '#1d75b3'
      style Literal::String::Symbol,          :fg => '#9c3328'
    end
  end
end
