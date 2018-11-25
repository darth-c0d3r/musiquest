

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Servlet implementation class ChangePassword
 */
@WebServlet("/ChangePassword")
public class ChangePassword extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public ChangePassword() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		HttpSession session = request.getSession();
		if(session.getAttribute("user_id") == null) { //not logged in
			response.getWriter().print(DbHelper.errorJson("Not logged in").toString());
			return;
		}
		
		int user_id = (Integer) session.getAttribute("user_id");
		String old_password = request.getParameter("old_password");
		String new_password = request.getParameter("new_password");
		
		String swear = Config.salt_domain;
		
		try {
			
			String query = "select password, salt from users where user_id = ?";
			List<List<Object>> res = DbHelper.executeQueryList(query, 
					new DbHelper.ParamType[] {DbHelper.ParamType.INT},
					new Object[] {user_id});
			
			MessageDigest md = MessageDigest.getInstance("SHA-256");
			md.reset();
			
			String password = (String) res.get(0).get(0);
			String salt = (String) res.get(0).get(1);
//			System.out.println(password);
//			System.out.println(salt);
			
			byte[] buffer = (salt+old_password).getBytes("UTF-8");
						
			md.update(buffer);
			byte[] digest = md.digest();

			String out = new String();
			for (int i = 0; i < digest.length; i++) {
				out +=  Integer.toString( ( digest[i] & 0xff ) + 0x100, 16).substring( 1 );
			}
			
			if(!out.equals(password)) {
				response.getWriter().print(DbHelper.errorJson("Old password is incorrect!").toString());
				return;
			}
			
			SecureRandom rand = new SecureRandom();
			byte salt1[] = new byte[9];
			rand.nextBytes(salt1);

			String salt1_str = "";
			for(int i=0;i<salt1.length;i++) {
				int ind = Math.abs(salt1[i])%swear.length();
				salt1_str += Character.toString(swear.charAt(ind));
			}
			
			byte[] buffer1 = (salt1_str+new_password).getBytes("UTF-8");
			md.reset();
			
			md.update(buffer1);
			byte[] digest1 = md.digest();

			String out1 = new String();
			for (int i = 0; i < digest1.length; i++) {
				out1 +=  Integer.toString( ( digest1[i] & 0xff ) + 0x100, 16).substring( 1 );
			}
			
			query = "update users set (password, salt) = (?,?) where user_id = ?";
			String json = DbHelper.executeUpdateJson(query, 
					new DbHelper.ParamType[] {DbHelper.ParamType.STRING,DbHelper.ParamType.STRING,  DbHelper.ParamType.INT},
					new Object[] {out1, salt1_str, user_id});
			
			response.getWriter().print(json);

		} catch (NoSuchAlgorithmException e) {
			System.out.println(e);
		} catch (UnsupportedEncodingException ex) {
			System.out.println(ex);	
		}
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		doGet(request, response);
	}

}
