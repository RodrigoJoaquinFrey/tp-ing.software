require 'rspec'
require_relative '../dominio/oferta'
require 'ostruct'

TITULO_OFERTA="Dev Ruby on Rails – Web App"
DESCRIPCION_OFERTA="Desarrollador Ruby on Rails para crear y optimizar aplicaciones web. Se requiere experiencia en desarrollo ágil y pruebas automatizadas."
MAIL_USUARIO = 'thorfinn@gmail.com'
TITULO_OFERTA_EXTENSO="Desarrollador Ruby on Rails – Proyecto Web Dinámico"

describe 'Oferta' do
    describe 'Inicializar oferta' do
      it 'Inicializar Oferta caso feliz' do
        resultado = Oferta.new(TITULO_OFERTA, DESCRIPCION_OFERTA, MAIL_USUARIO)
        expect(resultado.titulo).to eq TITULO_OFERTA
        expect(resultado.descripcion).to eq DESCRIPCION_OFERTA
      end

      it 'Inicializar Oferta con titulo vacio' do
        expect do
          Oferta.new(' ', DESCRIPCION_OFERTA, MAIL_USUARIO)
        end.to(raise_error(TituloVacioError))
      end

      it 'Inicializar Oferta con nombre con mayor a 30 caracteres' do
        expect do
          Oferta.new(TITULO_OFERTA_EXTENSO, DESCRIPCION_OFERTA, MAIL_USUARIO)
        end.to(raise_error(TituloExtensoError))
      end

      it 'Inicializar Oferta con descripcion vacia' do
        expect do
          Oferta.new(TITULO_OFERTA_EXTENSO, " ", MAIL_USUARIO)
        end.to(raise_error(TituloExtensoError))
      end

      it 'Se crea la oferta sin remuneracion pasada y da nil' do
        resultado = Oferta.new(TITULO_OFERTA, DESCRIPCION_OFERTA, MAIL_USUARIO)
        expect(resultado.remuneracion_ofrecida).to eq nil
      end

      it 'Se crea la oferta con remuneracion 20 y devuelve 20 como remuneracion' do
        resultado = Oferta.new(TITULO_OFERTA, DESCRIPCION_OFERTA, MAIL_USUARIO, {'remuneracion_ofrecida' => 20})
        expect(resultado.remuneracion_ofrecida).to eq 20
      end

      it 'Se crea la oferta con remuneracion con un caracter distinto a un numero entero positivo y lanza excepcion' do
        expect do
          oferta = Oferta.new(TITULO_OFERTA, DESCRIPCION_OFERTA, MAIL_USUARIO, {'remuneracion_ofrecida' => -2})
        end.to(raise_error(RemuneracionInvalidaError))
      end

      it 'se crea la oferta con ubicación'do
        resultado = Oferta.new(TITULO_OFERTA, DESCRIPCION_OFERTA, MAIL_USUARIO, {'ubicacion_oferta' => 'Buenos Aires' })
        expect(resultado.ubicacion_oferta).to eq 'Buenos Aires'
      end

      it 'se crea la oferta con ubicación menor a 3 caracteres y da error'do
        expect do
          oferta = Oferta.new(TITULO_OFERTA, DESCRIPCION_OFERTA, MAIL_USUARIO, {'ubicacion_oferta' => 'BS'})
        end.to(raise_error(UbicacionExtensionError))
      end

      it 'se crea la oferta con ubicación mayor a 50 caracteres y da error'do
        expect do
          oferta = Oferta.new(TITULO_OFERTA, DESCRIPCION_OFERTA, MAIL_USUARIO, {'ubicacion_oferta' => 'Avenida Corrientes 3456, Piso 7, Departamento B, Barrio de Almagro, Ciudad Autónoma de Buenos Aires, CP C1193AAF, Argentina'})
        end.to(raise_error(UbicacionExtensionError))
      end

      it 'Se crea la oferta sin edad minima de postulacion y da nil' do
        resultado = Oferta.new(TITULO_OFERTA, DESCRIPCION_OFERTA, MAIL_USUARIO)
        expect(resultado.edad_minima_postulacion).to eq nil
      end

      it 'Se crea la oferta con edad minima de postulacion 18 y devuelve 18' do
        resultado = Oferta.new(TITULO_OFERTA, DESCRIPCION_OFERTA, MAIL_USUARIO, {'edad_minima_postulacion' => 18})
        expect(resultado.edad_minima_postulacion).to eq 18
      end

      it 'Se crea la oferta con edad minima de postulacion un caracter NO entero entre 0 y 99, y lanza excepcion' do
        expect do
          oferta = Oferta.new(TITULO_OFERTA, DESCRIPCION_OFERTA, MAIL_USUARIO, {'edad_minima_postulacion' => -2})
        end.to(raise_error(EdadMinimaInvalidaError))
      end

      it 'se crea la oferta con etiquetas'do
        resultado = Oferta.new(TITULO_OFERTA, DESCRIPCION_OFERTA, MAIL_USUARIO, {'etiquetas' => ['ruby', 'tdd']})
        expect(resultado.etiquetas[0]).to eq 'ruby'
        expect(resultado.etiquetas[1]).to eq 'tdd'
      end

      it 'se crea la oferta con etiquetas con mas de 20 caracteres y lanza excepcion'do
        expect do
          Oferta.new(TITULO_OFERTA, DESCRIPCION_OFERTA, MAIL_USUARIO, {'etiquetas' => ['ruby on rails developer', 'tdd']})
        end.to(raise_error(EtiquetaExtensionError))
      end

      it 'se crea la oferta con etiquetas con menos de 3 caracteres y lanza excepcion'do
        expect do
          Oferta.new(TITULO_OFERTA, DESCRIPCION_OFERTA, MAIL_USUARIO, {'etiquetas' => ['js', 'tdd']})
        end.to(raise_error(EtiquetaExtensionError))
      end

      it 'se crea la oferta con mas de 5 etiquetas y lanza excepcion'do
        expect do
          Oferta.new(TITULO_OFERTA, DESCRIPCION_OFERTA, MAIL_USUARIO, {'etiquetas' => ['ruby', 'tdd', 'on rails', 'dev', 'job', 'scrum']})
        end.to(raise_error(EtiquetasCantidadError))
      end

      it 'se crea la oferta con etiquetas repetidas y lanza excepcion'do
        expect do
          Oferta.new(TITULO_OFERTA, DESCRIPCION_OFERTA, MAIL_USUARIO, {'etiquetas' => ['ruby', 'tdd', 'tdd']})
        end.to(raise_error(EtiquetasRepetidasError))
      end
    end

    describe 'postular a oferta' do
      it 'Se puede agregar un mail a la lista de mails de postulados' do
        oferta = Oferta.new(TITULO_OFERTA, DESCRIPCION_OFERTA, MAIL_USUARIO)
        oferta.agregar_mail_postulante(MAIL_USUARIO)
        expect(oferta.mails_de_postulantes[0]).to eq MAIL_USUARIO
      end

      it 'Si intento agregar un mail que ya está postulado en la oferta falla' do
        expect do
          oferta = Oferta.new(TITULO_OFERTA, DESCRIPCION_OFERTA, MAIL_USUARIO)
          oferta.agregar_mail_postulante(MAIL_USUARIO)
          oferta.agregar_mail_postulante(MAIL_USUARIO)
        end.to(raise_error(MailYaPostuladoError))
      end

    end
end
