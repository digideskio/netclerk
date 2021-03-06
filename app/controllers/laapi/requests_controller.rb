class Laapi::RequestsController < ApplicationController
  protect_from_forgery with: :null_session

  def show
    response.headers[ 'Access-Control-Allow-Origin' ] = '*'

    @request = Request.find(params[:id])

    response.headers[ 'Content-Type' ] = 'application/vnd.api+json'
    render json: @request.to_laapi
  end

  def create
    response.headers[ 'Access-Control-Allow-Origin' ] = '*'
    response.headers[ 'Content-Type' ] = 'application/vnd.api+json'

    attributes = request_params[ :attributes ]

    url = attributes[ :url ]
    page = Page.find_or_create_by url: url

    @request = Request.new( {
      page: page,
      country: Country.find_by( iso2: 'US' ),
      unproxied_ip: nil, # request locally
      proxied_ip: attributes[ :request_ip ],
      local_dns_ip: attributes[ :dns_ip ],
      response_time: attributes[ :response_content_time ],
      response_status: attributes[ :response_status ],
      response_headers: attributes[ :response_headers ],
      response_length: nil, # extract from header
      response_delta: 0 # compare to baseline_content
    } )

    if @request.save
      render json: @request.to_laapi
    else
      render json: { error: 500 }, status: 500
    end
  end

  private

  def request_params
    params.require( :data ).permit( :type, :attributes => [ :url, :country, :isp, :dns_ip, :request_ip, :request_headers, :redirect_headers, :response_status, :response_headers_time, :response_headers, :response_content_time, :response_content ] )
  end
end
