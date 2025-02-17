require 'redis'
require 'time'
require 'json'

require_relative '../dominio/errores'

class RepositorioOfertasRedis
  def initialize
    redis_url = ENV['REDIS_URL']
    redis_url = ENV['REDIS_DEV'] if ENV['RACK_ENV'] == 'development'
    redis_url = ENV['REDIS_TEST'] if ENV['RACK_ENV'] == 'test'

    @redis = Redis.new(url: redis_url)
  end

  def guardar(oferta)
    datos_oferta = {
      titulo: oferta.titulo,
      descripcion: oferta.descripcion,
      id_usuario: oferta.usuario.obtener_id,
      fecha_publicacion: oferta.fecha_publicacion,
      edad_minima: oferta.edad_minima,
      edad_maxima: oferta.edad_maxima
    }
    id = crear_id
    @redis.set("o:#{id}", datos_oferta.to_json)
    id
  end

  def encontrar(id_oferta)
    datos_json = @redis.get("o:#{id_oferta}")
    raise OfertaNoEncontrada, 'oferta no encontrada' if datos_json.nil? || datos_json.empty?

    datos_oferta = JSON.parse(datos_json)
    usuario = RepositorioUsuariosRedis.new.encontrar(datos_oferta['id_usuario'])

    datos = {'titulo' => datos_oferta['titulo'], 'descripcion' => datos_oferta['descripcion']}
    fecha = fecha_publicacion(datos_oferta['fecha_publicacion'])

    Oferta.new(datos, usuario, fecha,
               datos_oferta['edad_minima'], datos_oferta['edad_maxima'])
  end

  def guardar_actualizacion(oferta_actualizada, id_oferta)
    datos_oferta = {
      titulo: oferta_actualizada.titulo,
      descripcion: oferta_actualizada.descripcion,
      id_usuario: oferta_actualizada.usuario.obtener_id,
      fecha_publicacion: oferta_actualizada.fecha_publicacion,
      edad_minima: oferta_actualizada.edad_minima,
      edad_maxima: oferta_actualizada.edad_maxima
    }
    @redis.set("o:#{id_oferta}", datos_oferta.to_json)
    id_oferta
  end

  def crear_id
    size + 1
  end

  def size
    @redis.keys('o:*').size
  end

  def reset
    @redis.del(@redis.keys('o:*'))
  end

  def listar_todas
    lista_redis = []
    (1..size).each do |id|
      oferta = {id => JSON.parse(@redis.get("o:#{id}"))}
      lista_redis.append(oferta)
    end
    lista_redis
  end

  def encontrar_todas_id(id_usuario)
    lista_ofertas = []
    (1..size).each do |id|
      oferta = {id => JSON.parse(@redis.get("o:#{id}"))}
      lista_ofertas.append(oferta) if oferta[id]['id_usuario'] == id_usuario
    end
    lista_ofertas
  end

  private

  def fecha_publicacion(fecha)
    return Date.parse('1950-01-01') if fecha.nil?

    fecha
  end
end
