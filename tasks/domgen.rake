workspace_dir = File.expand_path(File.dirname(__FILE__) + "/..")

$LOAD_PATH.unshift(File.expand_path("#{workspace_dir}/../domgen/lib"))

require 'domgen'

Domgen::LoadSchema.new("#{workspace_dir}/architecture.rb")

generators = nil
if is_postgres?
  generators = [:pgsql]
  Domgen::Sql.dialect = Domgen::Sql::PgDialect
else
  generators = [:mssql]
  Domgen::Sql.dialect = Domgen::Sql::MssqlDialect
end

Domgen::GenerateTask.new(:Footprints, "sql", generators, "#{workspace_dir}/databases/generated") do |t|
  t.verbose = !!ENV['DEBUG_DOMGEN']
end
Domgen::Xmi::GenerateXMITask.new(:Footprints, "xmi", "#{workspace_dir}/target/xmi/footprints.xmi")
Domgen::GenerateTask.new(:Footprints, "active_record", [:active_record], "#{workspace_dir}/target/generated/main/ruby") do |t|
  t.description = 'Generates the ActiveRecord code for the persistent objects'
  t.verbose = !!ENV['DEBUG_DOMGEN']
end
