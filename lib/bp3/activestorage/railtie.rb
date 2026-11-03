# frozen_string_literal: true

# require 'rails/railtie'

# rubocop:disable-next Metrics/BlockLength
module Bp3
  module Activestorage
    if defined?(Rails.env)
      class Railtie < Rails::Railtie
        # to_prepare rather than after_initialize: Active Storage's models and controllers are reloaded
        # with the application's code in development, and what is added to them here goes with them.
        config.to_prepare do
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

              def self.table_name_basis
                table_name.gsub(/\Apublic\./, '').singularize
              end
            end

            class Blob
              include Bp3::Core::Rqid
              include Bp3::Core::Sqnr
              include Bp3::Core::Displayable
              include Bp3::Core::Ransackable

              # The key locates the file in storage, so it is not to be guessed at one character at a time
              self.unexplorable_columns = %w[key]

              use_sqnr_for_ordering
              has_paper_trail

              belongs_to :sites_site, class_name: 'Sites::Site', optional: true
              alias site sites_site
              alias site= sites_site=
              belongs_to :tenant, optional: true

              def self.table_name_basis
                table_name.gsub(/\Apublic\./, '').singularize
              end

              private

              def version_filter_mask
                '[FILTERED][AB]'
              end
            end

            class VariantRecord
              include Bp3::Core::Rqid
              include Bp3::Core::Sqnr
              include Bp3::Core::Ransackable

              use_sqnr_for_ordering
              has_paper_trail

              belongs_to :sites_site, class_name: 'Sites::Site', optional: true
              alias site sites_site
              alias site= sites_site=
              belongs_to :tenant, optional: true

              def self.table_name_basis
                table_name.gsub(/\Apublic\./, '').singularize
              end
            end

            class BaseController
              include Bp3::Core::Actions
              include Bp3::Core::Settings
              include Bp3::Core::FeatureFlags
              include Bp3::Core::Cookies

              # No login is asked of anyone fetching a file. The URL is signed, and holding it is the
              # permission: a visitor reading a page and an email client showing a logo have no session.
            end

            module Representations
              class ProxyController
                include Bp3::Core::Actions
                include Bp3::Core::Settings
                include Bp3::Core::FeatureFlags
                include Bp3::Core::Cookies

                # Like ActiveStorage::BaseController, asks no login: the signed URL is the permission.
              end
            end
          end
        end
      end
    end
  end
end
