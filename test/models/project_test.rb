require 'test_helper'

class ProjectTest < ActiveSupport::TestCase

  setup do
    @project = projects(:gbol5)
    @user = users(:default)
  end

  test 'should not save project without title' do
    project=Project.new
    assert_not project.save, 'Saved the project without a title'
  end

  test 'user should be assignable to project' do
    @project.users << @user
    assert_equal(1, @project.users.count, 'User could not be assigned to project')
  end

  test 'assign an individual to project' do
    @project.individuals << individuals(:first_specimen)
    assert_equal(1, @project.individuals.count, 'Individual could not be assigned to project')
  end

  test 'assign a species to project' do
    @project.species << species(:urtica)
    assert_equal(1, @project.species.count, 'Species could not be assigned to project')
  end

  test 'assign a family to project' do
    @project.families << families(:lentibulariaceae)
    assert_equal(1, @project.families.count, 'Family could not be assigned to project')
  end

  test 'assign an order to project' do
    @project.orders << orders(:lamiales)
    assert_equal(1, @project.orders.count, 'Order could not be assigned to project')
  end

  test 'assign a higher-order-taxon to project' do
    @project.higher_order_taxa << higher_order_taxa(:magnoliopsida)
    assert_equal(1, @project.higher_order_taxa.count, 'Higher-order-taxon could not be assigned to project')
  end


  test 'assign an isolate to project' do
    @project.isolates << isolates(:gbol5127)
    assert_equal(1, @project.isolates.count, 'Isolate could not be assigned to project')
  end

  test 'assign a contig to project' do
    @project.contigs << contigs(:gbol5127_matk)
    assert_equal(1, @project.contigs.count, 'Contign could not be assigned to project')
  end

  test 'assign a primer read to project' do
    @project.primer_reads << primer_reads(:gbol5127_uv17_uv18_T7promoter)
    assert_equal(1, @project.primer_reads.count, 'Primer read could not be assigned to project')
  end

  test 'assign an issue to project' do
    @project.issues << issues(:some_crap_happened)
    assert_equal(1, @project.issues.count, 'Issue  could not be assigned to project')
  end

  test 'assign a lab  to project' do
    @project.labs << labs(:bonn)
    assert_equal(1, @project.labs.count, 'Lab could not be assigned to project')
  end
end
