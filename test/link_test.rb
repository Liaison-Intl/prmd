require_relative 'helpers'

module Prmd
  class LinkTest < MiniTest::Test
    include PrmdLinkTestHelpers

    [
      {
        title: "no_required",
        required: {},
        optional: {"user:email" => "string", "user:name" => "string"}
      },
      {
        title: "parent_required",
        optional: {"user:email" => "string", "user:name" => "string"},
        required: {}
      },
      {
        title: "child_required",
        optional: {"user:name" => "string"},
        required: {"user:email" => "string"}
      },
      {
        title: "multiple_nested_required" ,
        optional: {"user:name" => "string",
                   "address:street" => "string",
                   "address:zip" => "string"},
        required: {"user:email" => "string"}
      },
      {
        title: "required_array_of_objects_with_optional_property" ,
        optional: {"users:name" => "string"},
        required: {"users:email" => "string"}
      }
    ].each do |test_hash|

      define_method "test_#{test_hash[:title]}" do
        subject = Prmd::Link.new( send("link_#{test_hash[:title]}"))
        required, optional = subject.required_and_optional_parameters

        assert_equal required, test_hash[:required]
        assert_equal optional, test_hash[:optional]
      end
    end

  end
end
