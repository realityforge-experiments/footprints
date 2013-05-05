package footprints.server;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Properties;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Id;
import javax.persistence.Persistence;
import javax.persistence.Table;
import org.geolatte.geom.DimensionalFlag;
import org.geolatte.geom.Point;
import org.geolatte.geom.PointSequenceBuilder;
import org.geolatte.geom.PointSequenceBuilders;
import org.geolatte.geom.Points;
import org.geolatte.geom.Polygon;
import org.geolatte.geom.crs.CrsId;

public class PostgisTest
{
  public static void main( String[] args )
  {
    String dburl = "jdbc:postgresql://127.0.0.1:5432/peter_Footprints_DEV";
    String dbuser = "stock-dev";
    String dbpass = "letmein";

    try
    {
      testDirectSQL( dburl, dbuser, dbpass );
      testJPA( dburl, dbuser, dbpass );
    }
    catch ( final Exception e )
    {
      System.err.println( "Aborted due to error:" );
      e.printStackTrace();
      System.exit( 1 );
    }
  }

  private static void testDirectSQL( final String dburl, final String dbuser, final String dbpass )
    throws Exception
  {
    final Connection conn;
    final String dropSQL =
      "drop table jdbc_test";
    final String createSQL =
      "create table jdbc_test (geom geometry, id int4)";
    final String insertPointSQL =
      "insert into jdbc_test values ('POINT (10 10 10)',1)";
    final String insertPolygonSQL =
      "insert into jdbc_test values ('POLYGON ((0 0 0,0 10 0,10 10 0,10 0 0,0 0 0))',2)";

    System.out.println( "Creating JDBC connection..." );
    Class.forName( "org.postgresql.Driver" );
    conn = DriverManager.getConnection( dburl, dbuser, dbpass );
    System.out.println( "Adding geometric type entries..." );

    ( (org.postgresql.PGConnection) conn ).addDataType( "geometry",
                                                        org.postgis.PGgeometry.class );
    ( (org.postgresql.PGConnection) conn ).addDataType( "box3d",
                                                        org.postgis.PGbox3d.class );

    Statement s = conn.createStatement();
    System.out.println( "Creating table with geometric types..." );
    // table might not yet exist
    try
    {
      s.execute( dropSQL );
    }
    catch ( Exception e )
    {
      System.out.println( "Error dropping old table: " + e.getMessage() );
    }
    s.execute( createSQL );
    System.out.println( "Inserting point..." );
    s.execute( insertPointSQL );
    System.out.println( "Inserting polygon..." );
    s.execute( insertPolygonSQL );
    System.out.println( "Done." );

    s = conn.createStatement();
    System.out.println( "Querying table..." );
    ResultSet r = s.executeQuery( "select st_asText(geom),id from jdbc_test" );
    while ( r.next() )
    {
      Object obj = r.getObject( 1 );
      int id = r.getInt( 2 );
      System.out.println( "Row " + id + ":" );
      System.out.println( obj.toString() );
    }
    s.close();
    conn.close();
  }

  private static void testJPA( final String dburl, final String dbuser, final String dbpass )
    throws Exception
  {
    final Properties properties = new Properties();
    properties.put( "javax.persistence.jdbc.driver", "org.postgresql.Driver" );
    properties.put( "javax.persistence.jdbc.url", dburl );
    properties.put( "javax.persistence.jdbc.user", dbuser );
    properties.put( "javax.persistence.jdbc.password", dbpass );
    properties.put( "javax.persistence.transactionType", "RESOURCE_LOCAL" );
    properties.put( "javax.persistence.jtaDataSource", "" );
    properties.put( "eclipselink.session-event-listener", ConverterInitializer.class.getName() );

    final EntityManagerFactory factory = Persistence.createEntityManagerFactory( "Footprints", properties );
    factory.getMetamodel().managedType( JdbcTest.class );

    EntityManager em = factory.createEntityManager();
    em.getTransaction().begin();
    System.out.println( "Removing data..." );
    em.createQuery( "DELETE FROM jdbctest" ).executeUpdate();
    System.out.println( "... data removed." );
    JdbcTest test = em.find( JdbcTest.class, 1 );
    if ( null != test )
    {
      throw new IllegalStateException( "Found result when unexpected" );
    }
    System.out.println( "Creating data..." );
    test = new JdbcTest();
    test.setGeom( Points.create2D( 1, 1 ) );
    test.setId( 1 );
    em.persist( test );
    em.flush();
    System.out.println( "... created data." );

    System.out.println( "Accessing data..." );
    test = em.find( JdbcTest.class, 1 );
    if ( null == test )
    {
      throw new IllegalStateException( "Failed to find result that just wrote" );
    }
    System.out.println( "Found: " + test.getId() + " - " + test.getGeom().toString() );
    em.getTransaction().commit();


    em.getTransaction().begin();
    System.out.println( "Removing data..." );
    em.createQuery( "DELETE FROM jdbctest" ).executeUpdate();
    System.out.println( "... data removed." );
    JdbcTest2 test2 = em.find( JdbcTest2.class, 1 );
    if ( null != test2 )
    {
      throw new IllegalStateException( "Found result when unexpected" );
    }
    System.out.println( "Creating data..." );
    test2 = new JdbcTest2();
    final PointSequenceBuilder builder =
      PointSequenceBuilders.variableSized( DimensionalFlag.d2D, CrsId.UNDEFINED );
    builder.add( 1, 1 );
    builder.add( 1, 0 );
    builder.add( 0, 0 );
    builder.add( 1, 1 );
    final Polygon geom = new Polygon( builder.toPointSequence() );
    test2.setGeom( geom );
    test2.setId( 1 );
    em.persist( test2 );
    em.flush();
    System.out.println( "... created data." );

    System.out.println( "Accessing data..." );
    test2 = em.find( JdbcTest2.class, 1 );
    if ( null == test2 )
    {
      throw new IllegalStateException( "Failed to find result that just wrote" );
    }
    System.out.println( "Found: " + test2.getId() + " - " + test2.getGeom().toString() );
    em.getTransaction().commit();

  }

  @Entity( name = "jdbctest" )
  @Table( name = "jdbc_test", schema = "public" )
  public static class JdbcTest
    implements java.io.Serializable
  {
    @Id
    @Column( name = "id" )
    private Integer id;

    @Column( name = "geom", columnDefinition = "geometry(POINT,-1)" )
    private Point geom;

    public Integer getId()
    {
      return id;
    }

    public void setId( final Integer id )
    {
      this.id = id;
    }

    public Point getGeom()
    {
      return geom;
    }

    public void setGeom( final Point geom )
    {
      this.geom = geom;
    }
  }


  @Entity( name = "jdbctest2" )
  @Table( name = "jdbc_test", schema = "public" )
  public static class JdbcTest2
    implements java.io.Serializable
  {
    @Id
    @Column( name = "id" )
    private Integer id;

    @Column( name = "geom" )
    private Polygon geom;

    public Integer getId()
    {
      return id;
    }

    public void setId( final Integer id )
    {
      this.id = id;
    }

    public Polygon getGeom()
    {
      return geom;
    }

    public void setGeom( final Polygon geom )
    {
      this.geom = geom;
    }
  }
}