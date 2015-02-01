# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :isolate do
    well_pos_plant_plate "MyString"
    lab_nr 1
    micronic_tube_id 1
    well_pos_micronic_plate "MyString"
    concentration "9.99"
  end
end
