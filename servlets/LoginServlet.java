

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Servlet implementation class LoginServlet
 */
@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	
    /**
     * @see HttpServlet#HttpServlet()
     */
    public LoginServlet() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
//		HttpSession session = request.getSession();
//		if(session.getAttribute("id") != null) { // logged in
//			response.getWriter().print(DbHelper.okJson().toString());
//		}
//		else {
//			response.getWriter().print(DbHelper.errorJson("Not logged in"));
//		}
		doPost(request, response);
		return;
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) 
			throws ServletException, IOException {
		HttpSession session = request.getSession();
		String userid = "p1";//request.getParameter("userid");
		String password = "Person1";//request.getParameter("password");
		
		try {
			String query = "select salt, password from users where username = ?";
			List<List<Object>> res = DbHelper.executeQueryList(query, 
					new DbHelper.ParamType[] {DbHelper.ParamType.STRING}, 
					new Object[] {userid});
			
			String salt_str = res.isEmpty()? null : (String)res.get(0).get(0);
			
			String hash = res.isEmpty()? null : (String)res.get(0).get(1);
			
			System.out.println(salt_str);
			System.out.println(hash);			

			MessageDigest md = MessageDigest.getInstance("SHA-256");
			md.reset();

			byte[] buffer = (salt_str+password).getBytes("UTF-8");
			md.update(buffer);
			byte[] digest = md.digest();

			String out = new String();
			for (int i = 0; i < digest.length; i++) {
				out +=  Integer.toString( ( digest[i] & 0xff ) + 0x100, 16).substring( 1 );
			}
			
			if(hash != null && hash.equals(out)) {
				session.setAttribute("id", userid);
				response.getWriter().print(DbHelper.okJson().toString());
			}
			else {
				response.getWriter().print(DbHelper.errorJson("Username/password incorrect or not registered").toString());
			}

		} catch (NoSuchAlgorithmException e) {
			System.out.println(e);
		} catch (UnsupportedEncodingException ex) {
			System.out.println(ex);	
		}
				
	}

}
