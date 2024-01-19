# frozen_string_literal: true

# require 'rails/railtie'

module Bp3
  module Activestorage
    if defined?(Rails.env)
      class Railtie < Rails::Railtie
        initializer 'bp3.activestorage.railtie.register' do |app|
          app.config.after_initialize do
            ::ActiveStorage::Attachment # preload
            ::ActiveStorage::Blob # preload
            ::ActiveStorage::VariantRecord # preload
            ::ActiveStorage::BaseController # preload
            ::ActiveStorage::Representations::ProxyController # preload
            module ::ActiveStorage
              # CAUTION: do not include Tenantable, it breaks things (it may set site/tenant behind the scenes,
              #   and sets the default scope, and then later the blob can't be found
              class Attachment
                include Bp3::Core::Rqid
                include Bp3::Core::Sqnr
                include Bp3::Core::Ransackable

                use_sqnr_for_ordering
                has_paper_trail

                belongs_to :sites_site, class_name: 'Sites::Site', optional: true
                alias site sites_site
                alias site= sites_site=
                belongs_to :tenant, optional: true
              end

              class Blob
                include Bp3::Core::Rqid
                include Bp3::Core::Sqnr
                include Bp3::Core::Displayable

                use_sqnr_for_ordering
                has_paper_trail

                belongs_to :sites_site, class_name: 'Sites::Site', optional: true
                alias site sites_site
                alias site= sites_site=
                belongs_to :tenant, optional: true

                private

                def version_filter_mask
                  '[FILTERED][AB]'
                end
              end

              class VariantRecord
                include Bp3::Core::Rqid
                include Bp3::Core::Sqnr

                use_sqnr_for_ordering
                has_paper_trail

                belongs_to :sites_site, class_name: 'Sites::Site', optional: true
                alias site sites_site
                alias site= sites_site=
                belongs_to :tenant, optional: true
              end

              class BaseController
                include Bp3::Core::Actions
                include Bp3::Core::Settings
                include Bp3::Core::FeatureFlags
                include Bp3::Core::Cookies

                # TODO: is this needed?
                # before_action :authenticate_root!
              end

              module Representations
                class ProxyController
                  include Bp3::Core::Actions
                  include Bp3::Core::Settings
                  include Bp3::Core::FeatureFlags
                  include Bp3::Core::Cookies

                  # using authenticate_root! breaks things
                  # TODO: is this needed?
                  # before_action :authenticate_root!
                end
              end
            end
          end
        end
      end
    end
  end
end
