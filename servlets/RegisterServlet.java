

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
 * Servlet implementation class RegisterServlet
 */
@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	
    /**
     * @see HttpServlet#HttpServlet()
     */
    public RegisterServlet() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doPost(request, response);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) 
			throws ServletException, IOException {
		HttpSession session = request.getSession();
		String username = request.getParameter("username");
		String password = request.getParameter("password");
		
		String swear = Config.salt_domain;
		
		try {
			SecureRandom rand = new SecureRandom();
			byte salt[] = new byte[9];
			rand.nextBytes(salt);

			String salt_str = "";
			for(int i=0;i<salt.length;i++) {
				int ind = Math.abs(salt[i])%swear.length();
				salt_str += Character.toString(swear.charAt(ind));
			}			

			MessageDigest md = MessageDigest.getInstance("SHA-256");
			md.reset();

			byte[] buffer = (salt_str+password).getBytes("UTF-8");
			md.update(buffer);
			byte[] digest = md.digest();

			String out = new String();
			for (int i = 0; i < digest.length; i++) {
				out +=  Integer.toString( ( digest[i] & 0xff ) + 0x100, 16).substring( 1 );
			}
			
			
			String query = "insert into users(username, password, salt) values (?, ?, ?)";
			String json = DbHelper.executeUpdateJson(query, 
					new DbHelper.ParamType[] {DbHelper.ParamType.STRING,DbHelper.ParamType.STRING,  DbHelper.ParamType.STRING},
					new String[] {username, out, salt_str});
			
			if(json.contains("\"status\":true")) {
				
				query = "select user_id from users where username = ?";
				
				List<List<Object>> res = DbHelper.executeQueryList(query, 
						new DbHelper.ParamType[] {DbHelper.ParamType.STRING}, 
						new Object[] {username});
				
				int user_id = (Integer) res.get(0).get(0);
				session.setAttribute("username", username);
				session.setAttribute("user_id", user_id);
				
				query = "insert into user_playlist(user_id, name, playlist_type) values (?,'My Queue',1)";
				DbHelper.executeUpdateJson(query, 
					new DbHelper.ParamType[] {DbHelper.ParamType.INT},
					new Object[] {user_id});
				
				query = "insert into user_playlist(user_id, name, playlist_type) values (?,'Made For You',2)";
				DbHelper.executeUpdateJson(query, 
					new DbHelper.ParamType[] {DbHelper.ParamType.INT},
					new Object[] {user_id});
			}
			response.getWriter().print(json);

		} catch (NoSuchAlgorithmException e) {
			System.out.println(e);
		} catch (UnsupportedEncodingException ex) {
			System.out.println(ex);	
		}
				
	}

}
