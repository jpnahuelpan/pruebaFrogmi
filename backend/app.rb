require './lib/pruebaFrogmi.rb'
require 'sinatra'
require 'json'
require 'faraday'
require 'rack/cors'
require 'mongo'

DATA = '{"saludo": "hola, acabo de reiniciar el compose!."}'
DATA2 = {
  saludo: "HOLA DESDE EL HILO."
}
client = Mongo::Client.new([ 'database:27017' ],
                           user: 'frogmi',
                           password: 'frogmipass',
                           database: 'frogmidb',
                           auth_source: 'admin')

coll_comments = client[:comments]
coll_features = client[:features]
insert = InsertFeatures.new(coll_features)

conn = Faraday.new(url: 'https://earthquake.usgs.gov') do |f|
  f.response :json
end

coll = Collector.new(conn)

validate_feature_coll = coll_features.find().first()


# verifica que la colección esté vacía para realizar in insercción masiva de datos.
if validate_feature_coll.nil?
  response = coll.get_by_key('features')
  puts insert.instert_init_data(response)
end

# Verifica (cada 60 segs) si hay nuevos datos y lo inserta en la colección.
Thread.new do
  loop do
    response = coll.get_by_key('features')
    insert.updating_features(response)
    sleep(60)
  end
end


get '/api/features' do
  page = params[:page]
  per_page = params[:per_page]
  mag_type = params[:mag_type]
  content_type :json

  query = Query.new(coll_features, page, per_page, mag_type)
  data = query.formating_features_for_serve
  data.to_json
end

post '/api/features/*/comments' do
  feature_id = params[:splat]
  request.body.rewind

  data = JSON.parse(request.body.read)

  content_type :json
  if !data['body'].empty?
    insert_comment = InsertComments.new(coll_comments, data, feature_id[0])
    response = insert_comment.response_for_post
    return response.to_json
  else
    status 400  # Bad Request
    return {error: 'El cuerpo de la solicitud está vacío'}.to_json
  end
end
