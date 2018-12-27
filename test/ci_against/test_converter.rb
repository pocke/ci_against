require 'test_helper'

class TestConverter < Minitest::Test
  def test_convert_add_ruby_2_6
    result = convert(<<~YAML)
      rvm:
        - 2.4.5
        - 2.5.3
    YAML
    assert_equal <<~YAML, result
      rvm:
        - 2.4.5
        - 2.5.3
        - 2.6.0
    YAML
  end

  def test_convert_update_teeny
    result = convert(<<~YAML)
      rvm:
        - 2.4.4
        - 2.5.0
    YAML
    assert_equal <<~YAML, result
      rvm:
        - 2.4.5
        - 2.5.3
        - 2.6.0
    YAML
  end

  def test_convert_travis_yml_has_other_section
    result = convert(<<~YAML)
      language: ruby
      rvm:
        - 2.4.4
        - 2.5.0
      script: bundle exec rake test
    YAML
    assert_equal <<~YAML, result
      language: ruby
      rvm:
        - 2.4.5
        - 2.5.3
        - 2.6.0
      script: bundle exec rake test
    YAML
  end

  def test_convert_not_ruby_project
    result = convert(<<~YAML)
      language: node_js
      node_js:
        - "iojs"
        - "7"
    YAML
    assert_equal <<~YAML, result
      language: node_js
      node_js:
        - "iojs"
        - "7"
    YAML
  end

  def test_convert_ruby_head
    result = convert(<<~YAML)
      rvm:
        - 2.4.4
        - 2.5.0
        - ruby-head
    YAML
    assert_equal <<~YAML, result
      rvm:
        - 2.4.5
        - 2.5.3
        - 2.6.0
        - ruby-head
    YAML
  end

  def test_convert_quoted
    result = convert(<<~YAML)
      rvm:
        - '2.4.4'
        - '2.5.0'
    YAML
    assert_equal <<~YAML, result
      rvm:
        - '2.4.5'
        - '2.5.3'
        - '2.6.0'
    YAML
  end

  def test_convert_flow_style
    skip 'Support Flow style'
    result = convert(<<~YAML)
      rvm: ['2.4.4', '2.5.0']
    YAML
    assert_equal <<~YAML, result
      rvm: ['2.4.5', '2.5.3', '2.6.0']
    YAML
  end

  def convert(yaml_string)
    CIAgainst::Converter.new(yaml_string).convert
  end
end
