
class config {
  static final ip = '10.42.0.1';
  static final port = '8080';
  static final project = 'DBProject';

  final login       = 'http://' + ip + ':' + port + '/' + project + '/LoginServlet';
  final register    = 'http://' + ip + ':' + port + '/' + project + '/RegisterServlet';
  final home        = 'http://' + ip + ':' + port + '/' + project + '/Homepage';
  final logout      = 'http://' + ip + ':' + port + '/' + project + '/LogoutServlet';
  final ConvDetail  = 'http://' + ip + ':' + port + '/' + project + '/ConversationDetail';
  final newMsg      = 'http://' + ip + ':' + port + '/' + project + '/NewMessage';
  final createConv  = 'http://' + ip + ':' + port + '/' + project + '/CreateConversation';
  final autoComp    = 'http://' + ip + ':' + port + '/' + project + '/AutoCompleteUser';
  final song        = 'http://' + ip + ':' + port + '/' + project + '/SongInfo';
  final updateSong  = 'http://' + ip + ':' + port + '/' + project + '/UpdateSong';
  final album       = 'http://' + ip + ':' + port + '/' + project + '/AlbumInfo';
  final updateAlbum = 'http://' + ip + ':' + port + '/' + project + '/UpdateAlbum';
  final artist      = 'http://' + ip + ':' + port + '/' + project + '/ArtistInfo';
  final updateArtist= 'http://' + ip + ':' + port + '/' + project + '/UpdateArtist';
  final APList      = 'http://' + ip + ':' + port + '/' + project + '/AllPlaylists';
  final UpdtList    = 'http://' + ip + ':' + port + '/' + project + '/AddToPlaylist';
  final playlist    = 'http://' + ip + ':' + port + '/' + project + '/PlaylistInfo';
  final crtpl       = 'http://' + ip + ':' + port + '/' + project + '/CreatePlaylist';
  final rmvpl       = 'http://' + ip + ':' + port + '/' + project + '/RemovePlaylist';
  final rmvfrompl   = 'http://' + ip + ':' + port + '/' + project + '/RemoveFromPlaylist';
  final search      = 'http://' + ip + ':' + port + '/' + project + '/SearchServlet';
}