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
      fecha_nacimiento: usuario.fecha_nacimiento
    }
    @redis.set("u:#{usuario.mail}", datos_usuario.to_json)
    usuario.mail
  end

  def size
    @redis.keys('u:*').size
  end

  def recuperar(mail_usuario)
    datos_usuario_json = @redis.get("u:#{mail_usuario}")
    return nil if datos_usuario_json.nil?

    datos_usuario = JSON.parse(datos_usuario_json)
    Usuario.new(datos_usuario['nombre'], datos_usuario['apellido'], datos_usuario['mail'],
                datos_usuario['fecha_nacimiento'])
  end

  def reset
    @redis.del(@redis.keys('u:*'))
  end
end
