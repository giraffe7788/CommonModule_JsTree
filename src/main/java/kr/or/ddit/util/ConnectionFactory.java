package kr.or.ddit.util;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.Properties;

import javax.sql.DataSource;

import org.apache.commons.dbcp.DriverManagerConnectionFactory;
import org.apache.commons.dbcp.PoolableConnection;
import org.apache.commons.dbcp.PoolableConnectionFactory;
import org.apache.commons.dbcp.PoolingDataSource;
import org.apache.commons.pool.impl.GenericObjectPool;

public class ConnectionFactory {
	
	private static interface Singleton {
		final ConnectionFactory INSTANCE = new ConnectionFactory();
	}
	
	private final DataSource dataSource;
	
	private ConnectionFactory() {
		Properties pro = new Properties();
		pro.setProperty("username", "jspexam");
		pro.setProperty("password", "java");
		
		try {
			loadDriver("oracle.jdbc.driver.OracleDriver");
		} catch (SQLException e) {
			e.printStackTrace();
		}
		
		GenericObjectPool<PoolableConnection> pool = new GenericObjectPool<PoolableConnection>();
		DriverManagerConnectionFactory connectionFactory = new DriverManagerConnectionFactory("jdbc:oracle:thin:@localhost:1521:xe", pro);
		new PoolableConnectionFactory(connectionFactory, pool, null, "SELECT 1", 3, false, false, Connection.TRANSACTION_READ_COMMITTED);
		
		this.dataSource = new PoolingDataSource(pool);
		
	}
	
	public static Connection getDatabaseConnection() throws SQLException {
		return Singleton.INSTANCE.dataSource.getConnection();
	}
	
	
	private static void loadDriver(String driver) throws SQLException {
		
		try {
			Class.forName(driver).newInstance();
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException e) {
			throw new SQLException("Unable to load driver : " + driver);
		}
	}
	

}
