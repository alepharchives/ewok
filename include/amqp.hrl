%%
%% amqp.hrl
%%
-define(PROTOCOL_VERSION_MAJOR, 8).
-define(PROTOCOL_VERSION_MINOR, 0).
-define(PROTOCOL_PORT, 5672).
-define(FRAME_METHOD, 1).
-define(FRAME_HEADER, 2).
-define(FRAME_BODY, 3).
-define(FRAME_OOB_METHOD, 4).
-define(FRAME_OOB_HEADER, 5).
-define(FRAME_OOB_BODY, 6).
-define(FRAME_TRACE, 7).
-define(FRAME_HEARTBEAT, 8).
-define(FRAME_MIN_SIZE, 4096).
-define(FRAME_END, 206).
-define(REPLY_SUCCESS, 200).
-define(NOT_DELIVERED, 310).
-define(CONTENT_TOO_LARGE, 311).
-define(NO_ROUTE, 312).
-define(NO_CONSUMERS, 313).
-define(ACCESS_REFUSED, 403).
-define(NOT_FOUND, 404).
-define(RESOURCE_LOCKED, 405).
-define(PRECONDITION_FAILED, 406).
-define(CONNECTION_FORCED, 320).
-define(INVALID_PATH, 402).
-define(FRAME_ERROR, 501).
-define(SYNTAX_ERROR, 502).
-define(COMMAND_INVALID, 503).
-define(CHANNEL_ERROR, 504).
-define(RESOURCE_ERROR, 506).
-define(NOT_ALLOWED, 530).
-define(NOT_IMPLEMENTED, 540).
-define(INTERNAL_ERROR, 541).
%% Method field records.
-record('connection.start', {version_major = 0, version_minor = 8, server_properties, mechanisms = <<"PLAIN">>, locales = <<"en_US">>}).
-record('connection.start_ok', {client_properties, mechanism = <<"PLAIN">>, response, locale = <<"en_US">>}).
-record('connection.secure', {challenge}).
-record('connection.secure_ok', {response}).
-record('connection.tune', {channel_max = 0, frame_max = 0, heartbeat = 0}).
-record('connection.tune_ok', {channel_max = 0, frame_max = 0, heartbeat = 0}).
-record('connection.open', {virtual_host = <<"/">>, capabilities = <<"">>, insist = false}).
-record('connection.open_ok', {known_hosts = <<"">>}).
-record('connection.redirect', {host, known_hosts = <<"">>}).
-record('connection.close', {reply_code, reply_text = <<"">>, class_id, method_id}).
-record('connection.close_ok', {}).
-record('channel.open', {out_of_band = <<"">>}).
-record('channel.open_ok', {}).
-record('channel.flow', {active}).
-record('channel.flow_ok', {active}).
-record('channel.alert', {reply_code, reply_text = <<"">>, details = []}).
-record('channel.close', {reply_code, reply_text = <<"">>, class_id, method_id}).
-record('channel.close_ok', {}).
-record('access.request', {realm = <<"/data">>, exclusive = false, passive = true, active = true, write = true, read = true}).
-record('access.request_ok', {ticket = 1}).
-record('exchange.declare', {ticket = 1, exchange, type = <<"direct">>, passive = false, durable = false, auto_delete = false, internal = false, nowait = false, arguments = []}).
-record('exchange.declare_ok', {}).
-record('exchange.delete', {ticket = 1, exchange, if_unused = false, nowait = false}).
-record('exchange.delete_ok', {}).
-record('queue.declare', {ticket = 1, queue = <<"">>, passive = false, durable = false, exclusive = false, auto_delete = false, nowait = false, arguments = []}).
-record('queue.declare_ok', {queue, message_count, consumer_count}).
-record('queue.bind', {ticket = 1, queue, exchange, routing_key, nowait = false, arguments = []}).
-record('queue.bind_ok', {}).
-record('queue.purge', {ticket = 1, queue, nowait = false}).
-record('queue.purge_ok', {message_count}).
-record('queue.delete', {ticket = 1, queue, if_unused = false, if_empty = false, nowait = false}).
-record('queue.delete_ok', {message_count}).
-record('queue.unbind', {ticket = 1, queue, exchange, routing_key, arguments}).
-record('queue.unbind_ok', {}).
-record('basic.qos', {prefetch_size = 0, prefetch_count = 0, global = false}).
-record('basic.qos_ok', {}).
-record('basic.consume', {ticket = 1, queue, consumer_tag, no_local = false, no_ack = false, exclusive = false, nowait = false}).
-record('basic.consume_ok', {consumer_tag}).
-record('basic.cancel', {consumer_tag, nowait = false}).
-record('basic.cancel_ok', {consumer_tag}).
-record('basic.publish', {ticket = 1, exchange = <<"">>, routing_key, mandatory = false, immediate = false}).
-record('basic.return', {reply_code, reply_text = <<"">>, exchange, routing_key}).
-record('basic.deliver', {consumer_tag, delivery_tag, redelivered = false, exchange, routing_key}).
-record('basic.get', {ticket = 1, queue, no_ack = false}).
-record('basic.get_ok', {delivery_tag, redelivered = false, exchange, routing_key, message_count}).
-record('basic.get_empty', {cluster_id = <<"">>}).
-record('basic.ack', {delivery_tag = 0, multiple = true}).
-record('basic.reject', {delivery_tag, requeue = true}).
-record('basic.recover', {requeue = false}).
-record('file.qos', {prefetch_size = 0, prefetch_count = 0, global = false}).
-record('file.qos_ok', {}).
-record('file.consume', {ticket = 1, queue, consumer_tag, no_local = false, no_ack = false, exclusive = false, nowait = false}).
-record('file.consume_ok', {consumer_tag}).
-record('file.cancel', {consumer_tag, nowait = false}).
-record('file.cancel_ok', {consumer_tag}).
-record('file.open', {identifier, content_size}).
-record('file.open_ok', {staged_size}).
-record('file.stage', {}).
-record('file.publish', {ticket = 1, exchange = <<"">>, routing_key, mandatory = false, immediate = false, identifier}).
-record('file.return', {reply_code = 200, reply_text = <<"">>, exchange, routing_key}).
-record('file.deliver', {consumer_tag, delivery_tag, redelivered = false, exchange, routing_key, identifier}).
-record('file.ack', {delivery_tag = 0, multiple = true}).
-record('file.reject', {delivery_tag, requeue = true}).
-record('stream.qos', {prefetch_size = 0, prefetch_count = 0, consume_rate = 0, global = false}).
-record('stream.qos_ok', {}).
-record('stream.consume', {ticket = 1, queue, consumer_tag = <<"">>, no_local = false, exclusive = false, nowait = false}).
-record('stream.consume_ok', {consumer_tag}).
-record('stream.cancel', {consumer_tag, nowait = false}).
-record('stream.cancel_ok', {consumer_tag}).
-record('stream.publish', {ticket = 1, exchange = <<"">>, routing_key, mandatory = false, immediate = false}).
-record('stream.return', {reply_code = 200, reply_text = <<"">>, exchange, routing_key}).
-record('stream.deliver', {consumer_tag, delivery_tag, exchange, queue}).
-record('tx.select', {}).
-record('tx.select_ok', {}).
-record('tx.commit', {}).
-record('tx.commit_ok', {}).
-record('tx.rollback', {}).
-record('tx.rollback_ok', {}).
-record('dtx.select', {}).
-record('dtx.select_ok', {}).
-record('dtx.start', {dtx_identifier}).
-record('dtx.start_ok', {}).
-record('tunnel.request', {meta_data}).
-record('test.integer', {integer_1, integer_2, integer_3, integer_4, operation}).
-record('test.integer_ok', {result}).
-record('test.string', {string_1, string_2, operation}).
-record('test.string_ok', {result}).
-record('test.table', {table, integer_op, string_op}).
-record('test.table_ok', {integer_result, string_result}).
-record('test.content', {}).
-record('test.content_ok', {content_checksum}).
%% Class property records.
-record('P_connection', {}).
-record('P_channel', {}).
-record('P_access', {}).
-record('P_exchange', {}).
-record('P_queue', {}).
-record('P_basic', {content_type, content_encoding, headers, delivery_mode, priority, correlation_id, reply_to, expiration, message_id, timestamp, type, user_id, app_id, cluster_id}).
-record('P_file', {content_type, content_encoding, headers, priority, reply_to, message_id, filename, timestamp, cluster_id}).
-record('P_stream', {content_type, content_encoding, headers, priority, timestamp}).
-record('P_tx', {}).
-record('P_dtx', {}).
-record('P_tunnel', {headers, proxy_name, data_name, durable, broadcast}).
-record('P_test', {}).