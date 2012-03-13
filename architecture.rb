Domgen.repository(:Footprints) do |repository|
  repository.enable_facet(:sql)
  repository.enable_facet(:ee)
  repository.enable_facet(:jpa)
  repository.enable_facet(:xml)
  repository.enable_facet(:json)
  repository.enable_facet(:jackson)
  repository.enable_facet(:jaxb)
  repository.enable_facet(:ruby)
  repository.enable_facet(:ejb)
  repository.enable_facet(:jws)
  repository.enable_facet(:imit)
  repository.enable_facet(:gwt)

  repository.jpa.provider = :eclipselink

  repository.data_module(:CodeMetrics) do |data_module|
    data_module.disable_facet(:imit)
    data_module.disable_facet(:gwt)

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

    data_module.struct(:MethodDTO) do |ss|
      ss.string(:PackageName, 500)
      ss.string(:ClassName, 500)
      ss.string(:MethodName, 500)

      # Non commenting source statements
      ss.integer(:NCSS)

      #Cyclomatic complexity
      ss.integer(:CCN)

      #Javadoc comments
      ss.integer(:JVDC)
    end

    data_module.struct(:CollectionDTO) do |s|
      s.integer(:ID)
      s.datetime(:CollectedAt)
      s.struct(:Method, :MethodDTO, :collection_type => :sequence)
    end

    data_module.service(:JavaNcss) do |s|
      s.ejb.generate_boundary = true
      s.method(:UploadJavaNcssOutput) do |m|
        m.text(:Output)
        m.exception(:FormatError)
      end
      s.method(:GetCollections) do |m|
        m.returns(:struct, :referenced_struct => :CollectionDTO, :collection_type => :sequence)
      end
      s.method(:GetCollection) do |m|
        m.integer(:ID)
        m.returns(:struct, :referenced_struct => :CollectionDTO)
      end
    end
  end

  repository.data_module(:TestModule) do |data_module|

    data_module.struct(:TaskDefinition) do |s|
      s.text(:Name)
      s.struct(:Child, :TaskDefinition, :collection_type => :set)
    end

    data_module.struct(:Fooish) do |s|
      s.text(:Project, :collection_type => :set)
      s.text(:ProjectNotes, :nullable => true)
      s.boolean(:Branch, :collection_type => :sequence)
      s.integer(:Version) do |a|
        a.xml.element = true
      end
      s.substruct(:Foo2) do |s2|
        s2.text(:Project2)
      end
      s.struct(:SomeName, :FooishFoo2)
    end

    data_module.entity(:BaseX, :final => false) do |t|
      t.integer(:ID, :primary_key => true)

      t.jpa.query('LookAtMe', "O.ID = :Foo OR O.ID = :ID OR :ElementType = '22'") do |q|
        q.description("Some reason to do stuff")
        q.integer(:Foo, :nullable => true)
        q.s_enum(:ElementType, { "PhysicalUnit" => "PhysicalUnit",
                                 "Crew" => "Crew",
                                 "RoleType" => "RoleType",
                                 "SpecificTask" => "SpecificTask",
                                 "TemplateTask" => "TemplateTask",
                                 "ManagementProject" => "ManagementProject",
                                 "TaskClassification" => "TaskClassification",
                                 "Classification" => "Classification" })

      end
    end

    data_module.enumeration(:CloneAction, :integer, :values => { "CLONE" => 0, "MOVE" => 1, "SKIP" => 2 }) do |e|
      e.description(<<-TEXT)
        The action that should be taken on resources when cloning the containing CrewRequirement or PositionRequirement.
        * CLONE : The resources should be copied into new structure
        * MOVE : The resources should be moved into new structure
        * SKIP : The resources should be left in the old structure
      TEXT
    end

    data_module.service(:Collector) do |s|
      s.ejb.generate_boundary = true
      s.ejb.remote = true

      s.description("Test Service definition")

      s.method(:RunAllTheTests) do |m|
        m.description("All the F#####g time!")
        m.boolean(:Force) do |p|
          p.description("Should we run all the tests or stop at first failing?")
        end
        m.s_enum(:Zing, { "X" => "X", "Y" => "Y" }, :collection_type => :sequence)
        m.exception(:TestsFailed)
        m.exception(:Problem)
      end

      s.method(:Subscribe) do |m|
        m.text(:SessionID, :"gwt.environment_key" => "request:session:id")
      end

      s.method(:SubscribeWithGuff) do |m|
        m.text(:SessionID, :"gwt.environment_key" => "request:session:id")
        m.text(:PermutationName, :"gwt.environment_key" => "request:permutation-strong-name")
        m.text(:SomeOtherParam, :collection_type => :set)
      end

      s.method(:CalculateResultValue) do |m|
        m.disable_facet(:jws)
        m.parameter(:Input, "java.math.BigDecimal")
        m.struct(:X,:Fooish)
        m.reference(:BaseX, :collection_type => :set)
        m.s_enum(:Zang, { "X" => "X", "Y" => "Y" }, :collection_type => :set)
        m.returns("java.math.BigDecimal", :nullable => true, :collection_type => :sequence)
        m.exception(:Problem)
      end
      s.method(:CalculateResultValue2) do |m|
        m.disable_facet(:jws)
        m.returns(:reference, :referenced_entity => :BaseX, :collection_type => :set)
      end
      s.method(:CalculateResultValue2B) do |m|
        m.disable_facet(:jws)
        m.returns(:struct, :referenced_struct => :TaskDefinition, :collection_type => :set)
      end
      s.method(:CalculateResultValue2C) do |m|
        m.disable_facet(:jws)
        m.returns(:struct, :referenced_struct => data_module.struct_by_name(:TaskDefinition) )
      end
      s.method(:CalculateResultValue3) do |m|
        m.disable_facet(:gwt)
        m.disable_facet(:imit)
        m.returns(:enumeration, :enumeration => data_module.enumeration_by_name(:CloneAction), :collection_type => :set)
      end
      s.method(:CalculateResultValue4) do |m|
        m.disable_facet(:jws)
        m.returns(:reference, :referenced_entity => :BaseX, :nullable => true, :collection_type => :set)
      end
    end

    data_module.entity(:Foo) do |t|
      t.integer(:ID, :primary_key => true)
      t.date(:A, :immutable => true)
      t.string(:ZX, 44, :immutable => true)
      t.text(:ZY, :immutable => true)
    end

    data_module.entity(:Bar) do |t|
      t.integer(:ID, :primary_key => true)
      t.reference(:Foo, :immutable => true)
    end

    data_module.message(:TimeRecorded) do |m|
      m.integer(:TimeEntryID, :collection_type => :set)
    end

    data_module.entity(:Tester) do |t|
      t.integer(:ID, :primary_key => true)
      t.date(:ADate, :immutable => true)
      t.date(:A, :immutable => true)
      t.date(:B, :nullable => true)
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

    data_module.entity(:ExtendedX, :extends => :BaseX, :final => false) do |t|
      t.string(:Name, 50, :immutable => true)
    end

    data_module.entity(:ExtendedExtendedX, :extends => :ExtendedX) do |t|
      t.string(:Description, 50, :immutable => true)
    end
  end

end
