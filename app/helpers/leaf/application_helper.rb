module Leaf
  module ApplicationHelper
    # FIXME need better name
    def devise_admin_model_name
      Leaf.devise_for.underscore.tr('/', '_')
    end
  end
end
