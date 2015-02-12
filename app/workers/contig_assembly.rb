class ContigAssembly

  include Sidekiq::Worker

  def perform(c_id)
    c=Contig.find(c_id)
    c.auto_overlap
  end

end