class SubscriptionPolicy < ApplicationPolicy
  def create?
    done_by_owner_or_admin?
  end

  def show?
    done_by_owner_or_admin?
  end

  def update?
    done_by_owner_or_admin?
  end

  def destroy?
    done_by_owner_or_admin? && !record.any_sold?
  end

  def permitted_attributes
    attributes = record.attribute_names.map(&:to_sym)
    #attributes.delete(:minimum_value) if record.any_sold?
    #attributes.delete(:deliver_at) if project_finished?
    attributes
  end

end


