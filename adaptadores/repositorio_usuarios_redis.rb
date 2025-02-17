require 'redis'
require 'time'
require 'json'

class RepositorioUsuariosRedis
  def initialize
    redis_url = ENV['REDIS_URL']
    redis_url = ENV['REDIS_DEV'] if ENV['RACK_ENV'] == 'development'
    redis_url = ENV['REDIS_TEST'] if ENV['RACK_ENV'] == 'test'

    @redis = Redis.new(url: redis_url)
  end

  def guardar(usuario)
    datos_usuario = {
      nombre: usuario.nombre,
      apellido: usuario.apellido,
      mail: usuario.mail,
      fecha_nacimiento: usuario.fecha_nacimiento,
      suscripcion: usuario.suscripcion.nombre
    }
    @redis.set("u:#{usuario.mail}", datos_usuario.to_json)
    usuario.mail
  end

  def size
    @redis.keys('u:*').size
  end

  def reset
    @redis.del(@redis.keys('u:*'))
  end

  def encontrar(mail_usuario)
    unless @redis.keys("u:#{mail_usuario}").empty?
      datos_usuario = JSON.parse(@redis.get("u:#{mail_usuario}"))
      datos_personales = {'nombre' => datos_usuario['nombre'],
                          'apellido' => datos_usuario['apellido'],
                          'mail' => datos_usuario['mail'],
                          'fecha_nacimiento' => datos_usuario['fecha_nacimiento']}
      suscripcion = datos_usuario['suscripcion']

      return Usuario.new(datos_usuario) if suscripcion.nil?

      return Usuario.new(datos_personales, suscripcion:)
    end

    nil
  end
end
