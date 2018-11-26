

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

import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;

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
		doPost(request,response);
		return;
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	@SuppressWarnings("unused")
	protected void doPost(HttpServletRequest request, HttpServletResponse response) 
			throws ServletException, IOException {
		HttpSession session = request.getSession();
		String username =  request.getParameter("username");
		String password =  request.getParameter("password");
		
		try {
			String type = "U";
			String query = "select salt, password from users where username = ?";
			List<List<Object>> res = DbHelper.executeQueryList(query, 
					new DbHelper.ParamType[] {DbHelper.ParamType.STRING}, 
					new Object[] {username});
			
			String salt_str = res.isEmpty()? null : (String)res.get(0).get(0);
			String hash = res.isEmpty()? null : (String)res.get(0).get(1);
			
			if(hash == null) {
				query = "select salt, password from admin where username = ?";
				res = DbHelper.executeQueryList(query, 
						new DbHelper.ParamType[] {DbHelper.ParamType.STRING}, 
						new Object[] {username});
				
				type = "A";
				salt_str = res.isEmpty()? null : (String)res.get(0).get(0);
				hash = res.isEmpty()? null : (String)res.get(0).get(1);
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
			
			if(hash != null && hash.equals(out)) {
				
				if(type == "U")
					query = "select user_id from users where username = ?";
				else
					query = "select user_id from admin where username = ?";
				
				res = DbHelper.executeQueryList(query, 
						new DbHelper.ParamType[] {DbHelper.ParamType.STRING}, 
						new Object[] {username});
				
				
				int user_id = (Integer)res.get(0).get(0);
				
				session.setAttribute("username", username);
				session.setAttribute("user_id", user_id);
				response.getWriter().print(type + DbHelper.okJson().toString());
				
				query = "with best_songs as (with final_score as (with song_score as (\n" + 
						"  (select user_id, user_song.song_id, album_id, artist_id, user_song.num_views as song_score from user_song,song where relation_type = 0 and song.song_id = user_song.song_id) \n" + 
						"UNION (select user_id, user_song.song_id, album_id, artist_id, (user_song.num_views + 10)*1.5  as score from user_song,song where relation_type = 1 and song.song_id = user_song.song_id) \n" + 
						"UNION (select user_id, user_song.song_id, album_id, artist_id, (user_song.num_views - 10)*0.5  as score from user_song,song where relation_type = -1 and song.song_id = user_song.song_id)),\n" + 
						"album_score as (\n" + 
						"  (select user_id, album_id, num_views as album_score from user_album where relation_type = 0) \n" + 
						"UNION (select user_id, album_id, (num_views + 10)*1.5  as score from user_album where relation_type = 1) \n" + 
						"UNION (select user_id, album_id, (num_views - 10)*0.5  as score from user_album where relation_type = -1)),\n" + 
						"artist_score as( \n" + 
						"      (select user_id, artist_id, num_views as artist_score from user_artist where relation_type = 0) \n" + 
						"UNION (select user_id, artist_id, (num_views + 10)*1.5  as score from user_artist where relation_type = 1) \n" + 
						"UNION (select user_id, artist_id, (num_views - 10)*0.5  as score from user_artist where relation_type = -1)),\n" + 
						"song_artist_score as \n" + 
						"(select song_score.user_id, song_id, album_id, song_score, coalesce(artist_score,0) as artist_score \n" + 
						"from song_score left outer join artist_score \n" + 
						"on (song_score.user_id, song_score.artist_id) = (artist_score.user_id, artist_score.artist_id)) \n" + 
						"select song_artist_score.user_id, song_id, song_score+coalesce(album_score,0)+artist_score as score \n" + 
						"from song_artist_score left outer join album_score \n" + 
						"on (song_artist_score.user_id, song_artist_score.album_id) = (album_score.user_id, album_score.album_id)),\n" + 
						"top_users as (select  all_user.user_id as their_id, ((count(*)^1.5)+5)/((sum(my_user.score - all_user.score)^2)+5) as similarity \n" + 
						"from (select * from final_score where user_id = ?) as my_user join final_score as all_user \n" + 
						"on my_user.song_id = all_user.song_id group by their_id order by similarity desc limit 10),\n" + 
						"temp as (select song_id, user_id, similarity from user_song join top_users on user_id = their_id) \n" + 
						"select song_id, sum(similarity*score) as song_rec from temp natural join final_score \n" + 
						"group by song_id order by song_rec desc limit 10) insert into song_playlist(song_id, playlist_id) select song_id, playlist_id from best_songs, user_playlist where user_id = ? and playlist_type = 2";
				
				JSONParser parser = new JSONParser();
				JSONObject json1 = new JSONObject();
				String res1 = DbHelper.executeUpdateJson(query, 
						new DbHelper.ParamType[] {DbHelper.ParamType.INT, DbHelper.ParamType.INT}, 
						new Object[] {user_id, user_id});
				
				try {
					json1 = (JSONObject) parser.parse(res1);
				} catch (ParseException e) {
					e.printStackTrace();
				};
				
//				response.getWriter().print(json1.toString());
			}
			else {
				response.getWriter().print(type + DbHelper.errorJson("Username/password incorrect or not registered").toString());
			}

		} catch (NoSuchAlgorithmException e) {
			System.out.println(e);
		} catch (UnsupportedEncodingException ex) {
			System.out.println(ex);	
		}
				
	}

}
