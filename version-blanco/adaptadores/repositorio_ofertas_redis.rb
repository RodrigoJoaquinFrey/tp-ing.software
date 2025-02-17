require 'redis'
require 'time'
require 'json'
require_relative '../dominio/oferta'

class RepositorioOfertasRedis
  def initialize
    redis_url = ENV['REDIS_URL']
    redis_url = ENV['REDIS_DEV'] if ENV['RACK_ENV'] == 'development'
    redis_url = ENV['REDIS_TEST'] if ENV['RACK_ENV'] == 'test'

    @redis = Redis.new(url: redis_url)
  end

  def guardar(oferta)
    id_oferta = oferta.id.nil? ? @redis.incr('oferta:id') : oferta.id
    datos_oferta = {
      id: id_oferta,
      titulo: oferta.titulo,
      descripcion: oferta.descripcion,
      mail: oferta.mail,
      remuneracion_ofrecida: oferta.remuneracion_ofrecida,
      ubicacion_oferta: oferta.ubicacion_oferta,
      edad_minima_postulacion: oferta.edad_minima_postulacion,
      mails_de_postulantes: oferta.mails_de_postulantes,
      etiquetas: oferta.etiquetas
    }
    @redis.set("o:#{id_oferta}", datos_oferta.to_json)
    id_oferta
  end

  def listar
    lista = []
    @redis.keys('o:*').each do |oferta_key|
      lista.append(recuperar(oferta_key.split(':')[1]))
    end
    lista
  end

  def recuperar(id_oferta)
    datos_oferta_json = @redis.get(armar_clave(id_oferta))
    raise IdOfertaInexistenteError if datos_oferta_json.nil?

    datos_oferta = JSON.parse(datos_oferta_json)
    Oferta.new(datos_oferta['titulo'], datos_oferta['descripcion'],
               datos_oferta['mail'], {'remuneracion_ofrecida' => datos_oferta['remuneracion_ofrecida'], 'ubicacion_oferta' => datos_oferta['ubicacion_oferta'], 'edad_minima_postulacion' => datos_oferta['edad_minima_postulacion'], 'etiquetas' => datos_oferta['etiquetas'], 'mails_de_postulantes' => datos_oferta['mails_de_postulantes'], 'id_oferta' => datos_oferta['id']})
  end

  def size
    @redis.keys('o:*').size
  end

  def reset
    @redis.del(@redis.keys('o:*'))
    @redis.del('oferta:id')
  end

  def buscar_por_titulo(titulo)
    ofertas_filtradas = listar.select do |oferta|
      oferta.titulo.downcase.include?(titulo)
    end

    ofertas_filtradas.map do |oferta|
      {
        id: oferta.id,
        titulo: oferta.titulo,
        descripcion: oferta.descripcion,
        mail: oferta.mail,
        remuneracion: oferta.remuneracion_ofrecida,
        ubicacion_oferta: oferta.ubicacion_oferta,
        edad_minima_postulacion: oferta.edad_minima_postulacion,
        etiquetas: oferta.etiquetas
      }
    end
  end

  def buscar_por_etiqueta(etiquetas)
    ofertas_filtradas = listar.select do |oferta|
      (etiquetas - oferta.etiquetas).empty? unless oferta.etiquetas.nil?
    end

    ofertas_filtradas.map do |oferta|
      {
        id: oferta.id,
        titulo: oferta.titulo,
        descripcion: oferta.descripcion,
        mail: oferta.mail,
        remuneracion: oferta.remuneracion_ofrecida,
        ubicacion_oferta: oferta.ubicacion_oferta,
        edad_minima_postulacion: oferta.edad_minima_postulacion,
        etiquetas: oferta.etiquetas
      }
    end
  end

  private

  def armar_clave(id_oferta)
    "o:#{id_oferta}"
  end
end
