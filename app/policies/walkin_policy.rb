class WalkinPolicy < ApplicationPolicy
  def new?    = user&.admin?
  def create? = user&.admin?
end
