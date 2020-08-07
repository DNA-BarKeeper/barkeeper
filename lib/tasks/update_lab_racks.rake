namespace :data do
  task update_lab_racks: :environment do
    LabRack.all.each do |lr|
      shelf = Shelf.find_by_name(lr.shelf_name)
      if shelf
        lr.update(shelf: shelf)
        puts '.'
      else
        puts '!'
      end
    end
  end
end