import java.sql.*;

public class p2 {

    // JDBC Objects
	private static Connection con;
    private static String username;
	private static String password;
    private static String url;
   
    /**
	 * Create a new customer.
	 * @param name customer name
	 * @param gender customer gender
	 * @param age customer age
	 * @param pin customer pin
	 */
    public static void newCustomer(String name, String gender, String age, String pin) throws Exception
    {
        con = DriverManager.getConnection(url,username,password);
        CallableStatement cst = con.prepareCall("{ call P2.CUST_CTR(?,?,?,?,?,?,?) }");

        //create CUS1
        cst.setString(1, "CUS1");
        cst.setString(2, "M");
         //create CUS2
        cst.setString(1, "CUS2");
        cst.setString(2, "F");
         //create CUS3
        cst.setString(1, "CUS3");
        cst.setString(2, "M");

        cst.setInt(3,20);
        cst.setInt(4, 1111);

        cst.setInt(3,25);
        cst.setInt(4, 2222);

        cst.setInt(3,40);
        cst.setInt(4, 3333);

        cst.registerOutParameter(5, Types.INTEGER);
        cst.registerOutParameter(6, Types.VARCHAR);
        cst.registerOutParameter(7, Types.VARCHAR);

        cst.execute();
        con.close();
    }

    /**
	 * Open a new account.
	 * @param id customer id
	 * @param type type of account
	 * @param amount initial deposit amount
	 */
	public static void authCustomer(String id, String pin) throws Exception{

        con = DriverManager.getConnection(url, username, password);
        CallableStatement cst = con.prepareCall("{ call P2.CUST_LOGIN(?,?,?,?,?) }");

        //customer login
        cst.setInt(1, 100);
        cst.setInt(2, 1111);

        //customer login error cases
        cst.setInt(1, 102);
        cst.setInt(2, 1111);
         //customer login error cases
         cst.setInt(1, 999);
         cst.setInt(2, 9999);


        cst.registerOutParameter(3, Types.INTEGER);
        cst.registerOutParameter(4, Types.VARCHAR);
        cst.registerOutParameter(5, Types.VARCHAR);

        cst.execute();
        con.close();
    }

    /**
	 * Account Option.
	 * @param id customer id
	 * @param balance in account
	 * @param type account
	 */
	public static void openAccount(String id, String balance, String type) throws Exception{
        con = DriverManager.getConnection(url, username, password);
        CallableStatement cst = con.prepareCall("{ call P2.ACCT_OPN(?,?,?,?,?,?) }");

        //open with invalid id
        cst.setInt(1, 100);
        cst.setDouble(2, 100);

        cst.setInt(1, 100);
        cst.setDouble(2, 200);

        cst.setInt(1, 101);
        cst.setDouble(2, 300);

        cst.setInt(1, 101);
        cst.setDouble(2, 400);

        cst.setInt(1, 102);
        cst.setDouble(2, 500);

        cst.setInt(1, 102);
        cst.setDouble(2, 600);

        
        //open with invalid id
        cst.setInt(1, 999);
        cst.setDouble(2, 500);

        //open with invalid balance
        cst.setInt(1, 100);
        cst.setDouble(2, -100);

        
        cst.setString(3, "C");
        cst.setString(3, "S");
        cst.registerOutParameter(3, Types.INTEGER);
        cst.registerOutParameter(4, Types.VARCHAR);
        cst.registerOutParameter(5, Types.VARCHAR);

        cst.execute();
        con.close();
    }

    /**
	 * Close an account.
	 * @param accNum account number
	 */
    public static void closeAccount(String accNum) throws Exception
	{
        con = DriverManager.getConnection(url, username, password);
        CallableStatement cst = con.prepareCall("{ call P2.ACCT_CLS(?,?,?) }");

        //close account
        cst.setInt(1, 1004);

        //close invalid account
        cst.setInt(1, 9999);

        cst.registerOutParameter(3, Types.INTEGER);
        cst.registerOutParameter(4, Types.VARCHAR);
        cst.execute();
        con.close();
    }

    /**
	 * Deposit into an account.
	 * @param accNum account number
	 * @param amount deposit amount
	 */
    public static void deposit(String accNum, String amount) throws Exception
	{
        con = DriverManager.getConnection(url, username, password);
        CallableStatement cst = con.prepareCall("{ call P2.ACCT_DEP(?,?,?,?) }");

        //deposit into account
        cst.setInt(1, 1000);
        cst.setInt(2, 33);

        //deposit into invalid account
        cst.setInt(1, 9999);
        cst.setInt(2, 44);

        //deposit with negative balance
        cst.setInt(1, 1001);
        cst.setInt(2, -44);

        cst.setInt(1, 1004);
        cst.setInt(2, 99);

        cst.registerOutParameter(3, Types.VARCHAR);
        cst.registerOutParameter(4, Types.VARCHAR);

        cst.execute();
        con.close();
    }

    /**
	 * Withdraw from an account.
	 * @param accNum account number
	 * @param amount withdraw amount
	 */
	public static void withdraw(String accNum, String amount) throws Exception
	{
        con = DriverManager.getConnection(url, username, password);
        CallableStatement cst = con.prepareCall("{ call P2.ACCT_WTH(?,?,?,?) }");

        // withdraw from account
        cst.setInt(1, 1000);
        cst.setInt(2, 22);
        
        // over drawn
        cst.setInt(1, 1002);
        cst.setInt(2, 2000);

        cst.setInt(1, 1003);
        cst.setInt(2, -88);

        cst.registerOutParameter(3, Types.VARCHAR);
        cst.registerOutParameter(4, Types.VARCHAR);
        cst.execute();
        con.close();
    }

    /**
	 * Transfer amount from source account to destination account.
	 * @param srcAccNum source account number
	 * @param destAccNum destination account number
	 * @param amount transfer amount
	 */
	public static void transfer(String srcAccNum, String destAccNum, String amount) throws Exception
	{
        con = DriverManager.getConnection(url, username, password);
        CallableStatement cst = con.prepareCall("{ call P2.ACCT_TRX(?,?,?,?,?) }");

        // transfer to another account
        cst.setInt(1, 1003);
        cst.setInt(2, 1002);
        cst.setInt(3, 66);

        //different customer
        cst.setInt(1, 1005);
        cst.setInt(2, 1000);
        cst.setInt(3, 99);

        cst.registerOutParameter(3, Types.VARCHAR);
        cst.registerOutParameter(4, Types.VARCHAR);
        cst.execute();
        con.close();    
    }

    /**
	 * Calculate customer's interest.
	 * @param saving_rate customer saving rate
     * @param checking_rate  customer checking rate
	 */
	public static void customerInterest(String saving_rate, String checking_rate) throws Exception
	{
        con = DriverManager.getConnection(url, username, password);
        CallableStatement cst = con.prepareCall("{ call P2.ADD_INTEREST(?,?,?,?) }");

        //interest
        cst.setDouble(1, 0.5);
        cst.setDouble(2, 0.1);
        cst.registerOutParameter(3, Types.VARCHAR);
        cst.registerOutParameter(3, Types.VARCHAR);
        cst.execute();
        con.close();
    }


} //p2
