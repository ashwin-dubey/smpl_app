module Api
  def self.BasicCrud(options={})
    Module.new do
      @ops = options[:only] || 'CRUD'
      @model = options[:model]
      @output_filters =  options[:output_filters]
      class << self
        def included(klass)
          @klass = klass
          set_model_name

          if @ops.include?('R')
            include_reads(@output_filters)
          end
          if @ops.include?('U')
            include_update
          end

          if @ops.include?('C')
            include_create
          end

        end

        def include_reads(filters)
          @klass.class_eval do
            get '/' do
              param_filters = (params[:filters] || {}).slice(*crud_model.column_names)
              res = with_pagination(crud_model.where(param_filters))
              res[:data] = res[:data].collect{|d| send(filters[0],d)} if filters&.[](0)
              res.to_json
            end

            get '/:id' do |id|
              data = crud_model.find(id) rescue return_errors('no resource exists', 400)
              filter = filters&.[](0)
              data = send(filter, data) if filter
              (data.respond_to?(:as_co) ? data.as_co : data).to_json
            end
          end
        end

        def include_update
          @klass.class_eval do
            put '/:id' do |id|
              r = crud_model.find(id)
              if r.update(params[:data])
                CurrentRequest.resource(r.send(crud_model.primary_key), crud_model.name)
                r.run_triggers.to_json
              else
                return_errors(r.errors.messages, 400)
              end
            end
          end
        end

        def include_create
          @klass.class_eval do
            post '/' do
              r = crud_model.create(params[:data])
              if r.persisted?
                r.to_json
              else
                return_errors(r.errors.messages, 400)
              end
            end
          end
        end

        def set_model_name
          @model ||= @klass.to_s.match(/::([a-zA-Z]+)Handler/)&.[](1)&.singularize.constantize
          begin
            @klass.instance_variable_set(:'@crud_model', @model)
            @klass.instance_eval { def crud_model; @crud_model; end }
            @klass.class_eval {
              def crud_model
                @crud_model ||= begin; cm = self.class.crud_model; cm.is_a?(Proc) ? cm.(self) : cm; end
              end
            }
          rescue => e
            Api.error("Error defining model for BasicCrud:#{@klass}")
            raise e
          end
        end

        def apply_filter(data, filter)
          if filter.present?
            .to_json
          else
            data.to_json
          end
        end
      end
    end
  end
end
