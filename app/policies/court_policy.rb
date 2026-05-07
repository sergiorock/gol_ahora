class CourtPolicy < ApplicationPolicy
  def index?   = true
  def show?    = true
  def new?     = user.admin?
  def create?  = user.admin?
  def edit?    = user.admin?
  def update?  = user.admin?
  def destroy? = user.admin?
end
