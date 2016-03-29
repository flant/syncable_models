FactoryGirl.define do
  factory :first_project, class: Project do
    name "First"
    uuid SecureRandom.uuid
  end

  factory :second_project, class: Project do
    name "Second"
    uuid SecureRandom.uuid
  end

  factory :third_project, class: Project do
    name "Third"
    uuid SecureRandom.uuid
  end

  factory :fourth_project, class: Project do
    name "fourth"
    uuid SecureRandom.uuid
  end
end
