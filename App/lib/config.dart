
class config {
  static final ip = '10.196.8.197';
  static final port = '8080';
  static final project = 'musi_quest_1';

  final login       = 'http://' + ip + ':' + port + '/' + project + '/LoginServlet';
  final register    = 'http://' + ip + ':' + port + '/' + project + '/RegisterServlet';
  final home        = 'http://' + ip + ':' + port + '/' + project + '/Homepage';
  final logout      = 'http://' + ip + ':' + port + '/' + project + '/LogoutServlet';
  final ConvDetail  = 'http://' + ip + ':' + port + '/' + project + '/ConversationDetail';
  final newMsg      = 'http://' + ip + ':' + port + '/' + project + '/NewMessage';
  final createConv  = 'http://' + ip + ':' + port + '/' + project + '/CreateConversation';
  final autoComp    = 'http://' + ip + ':' + port + '/' + project + '/AutoCompleteUser';
}