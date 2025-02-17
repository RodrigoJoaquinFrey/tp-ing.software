require 'sendgrid-ruby'
require 'ostruct'

class ManejadorMail
  include SendGrid

  def send_mail(mail_oferente, titulo_oferta, nombre_postulante, apellido_postulante, mail_postulante)
    if ENV['RACK_ENV'] == 'development' || ENV['RACK_ENV'] == 'test'
      return OpenStruct.new(status_code: '202')
    end

    de = Email.new(email: ENV['MAIL_JOBVACANCY'])
    para = Email.new(email: mail_oferente)
    asunto = "Tienes una nueva postulación para #{titulo_oferta}"
    cuerpo = Content.new(type: 'text/plain', value: "Tienes una nueva postulación para #{titulo_oferta}:
                #{nombre_postulante} #{apellido_postulante}
                #{mail_postulante}

                Gracias")
    mail = Mail.new(de, asunto, para, cuerpo)

    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
    sg.client.mail._('send').post(request_body: mail.to_json)
  end
end
