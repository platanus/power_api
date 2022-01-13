module PowerApi::GeneratorHelper::TemplateBuilderHelper
  extend ActiveSupport::Concern

  def concat_tpl_statements(*methods)
    methods.reject(&:blank?).join("\n")
  end

  def concat_tpl_method(method_name, *method_lines)
    concat_tpl_statements(
      "def #{method_name}",
      *method_lines,
      "end"
    )
  end

  def tpl_class(class_def, *statements)
    concat_tpl_statements(
      "class #{class_def}",
      *statements,
      "end\n"
    )
  end
end
