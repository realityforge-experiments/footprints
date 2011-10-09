Domgen.repository(:footprints) do |repository|
  repository.enable_facet(:sql)
  repository.enable_facet(:jpa)
  repository.enable_facet(:ruby)
  repository.enable_facet(:ejb)
  repository.enable_facet(:imit)

  repository.data_module(:CodeMetrics) do |data_module|
    data_module.jpa.entity_package = 'footprints.javancss.model'
    data_module.imit.imitation_package = 'footprints.javancss.imit'

    data_module.entity(:Collection) do |t|
      t.integer(:ID, :primary_key => true)
      t.datetime(:CollectedAt, :immutable => true)
    end

    data_module.entity(:MethodMetric) do |t|
      t.integer(:ID, :primary_key => true)
      t.reference(:Collection, :immutable => true) do |a|
        a.inverse.traversable = true
      end
      t.string(:PackageName, 500, :immutable => true)
      t.string(:ClassName, 500, :immutable => true)
      t.string(:MethodName, 500, :immutable => true)

      # Non commenting source statements
      t.integer(:NCSS, :immutable => true)

      #Cyclomatic complexity
      t.integer(:CCN, :immutable => true)

      #Javadoc comments
      t.integer(:JVDC, :immutable => true)
    end
  end

  repository.data_module(:BaseTestModule) do |data_module|
    data_module.jpa.entity_package = 'footprints.base_tester.model'
    data_module.imit.imitation_package = 'footprints.base_tester.imit'

    data_module.entity(:BaseX, :final => false) do |t|
      t.integer(:ID, :primary_key => true)
    end
  end


  repository.data_module(:TestModule) do |data_module|
    data_module.jpa.entity_package = 'footprints.tester.model'
    data_module.imit.imitation_package = 'footprints.tester.imit'

    data_module.service(:Collector) do |s|

      s.description("Test Service definition")

      s.method(:RunAllTheTests) do |m|
        m.description("All the F#####g time!")
        m.parameter(:Force, :boolean) do |p|
          p.description("Should we run all the tests or stop at first failing?")
        end
        m.exception(:TestsFailed)
        m.exception(:Foo)
      end

      s.method(:CalculateResultValue) do |m|
        m.parameter(:Input, "java.math.BigDecimal")
        m.returns("java.math.BigDecimal", :nullable => true)
        m.exception(:Foo)
      end
    end

    data_module.service(:MyService) do |s|

      s.method(:DoStuff) do |m|
        m.exception(:Foo)
      end
    end

    data_module.entity(:Foo) do |t|
      t.integer(:ID, :primary_key => true)
      t.datetime(:A, :immutable => true)
    end

    data_module.entity(:Bar) do |t|
      t.integer(:ID, :primary_key => true)
      t.reference(:Foo, :immutable => true)
    end

    data_module.entity(:Tester) do |t|
      t.integer(:ID, :primary_key => true)
      t.datetime(:A, :immutable => true)
      t.datetime(:B, :nullable => true)
      t.integer(:C, :nullable => true)
      t.integer(:D, :nullable => true)
      t.integer(:E, :nullable => true)
      t.integer(:F, :nullable => true)
      t.reference(:Foo, :immutable => true) do |a|
        a.inverse.multiplicity = :one
        a.inverse.traversable = true
      end
      t.reference(:Bar) do |a|
        a.inverse.traversable = true
      end

      t.sql.constraint("TestConstraint", :sql => "#{Domgen::Sql.dialect.quote("A")} IS NOT NULL")
      t.sql.index([:B], :filter => "#{Domgen::Sql.dialect.quote("B")} IS NOT NULL", :unique => true)

      t.cycle_constraint(:Bar, [:Foo])
      t.unique_constraint([:C])
      t.incompatible_constraint([:B, :C])
      t.dependency_constraint(:D, [:E])
      t.codependent_constraint([:E, :F])

      t.relationship_constraint(:eq, :A, :B)
      t.relationship_constraint(:neq, :A, :B)
      t.relationship_constraint(:gt, :A, :B)
      t.relationship_constraint(:lt, :A, :B)
      t.relationship_constraint(:gte, :A, :B)
      t.relationship_constraint(:lte, :A, :B)
      t.relationship_constraint(:lte, :C, :D)
      t.i_enum(:LinkType, { "URL" => 0, "JAVA" => 1 }) do |a|
        a.description(<<TEXT)
  The type of the link.

  * A link that starts an external browser using the URL derived from the Target attribute.
  * A link that invokes some java code with the class name specified in the Target attribute.
TEXT
        t.s_enum(:ElementType, { "PhysicalUnit" => "PhysicalUnit",
                                 "Crew" => "Crew",
                                 "RoleType" => "RoleType",
                                 "SpecificTask" => "SpecificTask",
                                 "TemplateTask" => "TemplateTask",
                                 "ManagementProject" => "ManagementProject",
                                 "TaskClassification" => "TaskClassification",
                                 "Classification" => "Classification" })
      end

    end

    data_module.entity(:ExtendedX, :extends => :"BaseTestModule.BaseX", :final => false) do |t|
      t.string(:Name, 50, :immutable => true)
    end

    data_module.entity(:ExtendedExtendedX, :extends => :ExtendedX) do |t|
      t.string(:Description, 50, :immutable => true)
    end
  end

end
