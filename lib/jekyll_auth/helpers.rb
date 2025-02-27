# frozen_string_literal: true

class JekyllAuth
  module Helpers
    def whitelisted?
      return true if request.path_info == "/logout"

      !!(JekyllAuth.whitelist && JekyllAuth.whitelist.match(request.path_info))
    end
    def matches_level?(arg)
      return true if request.path_info == "/logout"
      !!(JekyllAuth.levels(arg) && JekyllAuth.levels(arg).match(request.path_info))
    end
    def authentication_strategy(arg)
      if !ENV["GITHUB_TEAM_ID_#{arg}"].to_s.blank?
        :team
      elsif !ENV["GITHUB_TEAM_IDS_#{arg}"].to_s.blank?
        :teams
      elsif !ENV["GITHUB_ORG_NAME_#{arg}"].to_s.blank?
        :org
      end
    end
  end
end
