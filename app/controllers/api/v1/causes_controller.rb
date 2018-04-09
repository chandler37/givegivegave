module Api
  module V1
    class CausesController < ::NonRailsAdminApplicationController
      # There should be no need to separate the ability to create/update a
      # cause from the ability to associate a cause with a charity.
      load_and_authorize_resource except: [:create]

      # GET /api/v1/causes
      # GET /api/v1/causes.json
      def index
        # TODO(chandler37): kaminari pagination support

        # TODO(chandler37): Algolia search integration over this tiny, tiny
        # corpus for autocompletion's sake
        if params[:search].present?
          @causes = Cause.table_scan_search(params[:search])
        end
      end

      # GET /api/v1/causes/1
      # GET /api/v1/causes/1.json
      def show
      end

      # POST /api/v1/causes
      # POST /api/v1/causes.json
      # POST /api/v1/charities/:charity_id/causes
      # POST /api/v1/charities/:charity_id/causes.json
      def create
        authorize! :create, Cause
        if params[:charity_id].present?
          cause_param = params.require(:cause)
          if cause_param[:id].blank? || cause_param[:id].to_i == 0
            render json: {"cause[:id]" => "required integer"}, status: :unprocessable_entity
            return
          end
          @cause = Cause.find(cause_param[:id].to_i)
          charity = Charity.find(params[:charity_id].to_i)
          @cause.charities << charity
          respond_to do |format|
            format.html {
              redirect_to(
                api_charity_url(charity),
                notice: 'Cause was successfully associated with this charity.'
              )
            }
            format.json { head :no_content }
          end
        else
          @cause = Cause.new(cause_params)
          if @cause.parent_id && Cause.find_by(id: @cause.parent_id).nil?
            render json: {"parent_id" => ["Parent does not exist"]}, status: :unprocessable_entity
            return
          end
          respond_to do |format|
            if @cause.save
              format.html { redirect_to(api_cause_url(@cause), notice: 'Cause was successfully created.') }
              format.json { render :show, status: :created, location: api_cause_url(@cause) }
            else
              format.html { render json: @cause.errors, status: :unprocessable_entity } # TODO(chandler37): show proper html for this rare case
              format.json { render json: @cause.errors, status: :unprocessable_entity }
            end
          end
        end
      end

      # PATCH/PUT /api/v1/causes/1
      # PATCH/PUT /api/v1/causes/1.json
      def update
        respond_to do |format|
          if @cause.update(cause_params)
            format.html { redirect_to(api_cause_url(@cause), notice: 'Cause was successfully updated.') }
            format.json { render :show, status: :ok, location: api_cause_url(@cause) }
          else
            format.html { render json: @cause.errors, status: :unprocessable_entity } # TODO(chandler37): show proper html for this rare case
            format.json { render json: @cause.errors, status: :unprocessable_entity }
          end
        end
      end

      # DELETE /api/v1/causes/1
      # DELETE /api/v1/causes/1.json
      # DELETE /api/v1/charities/:charity_id/causes/:id
      # DELETE /api/v1/charities/:charity_id/causes/:id.json
      def destroy
        Cause.transaction do
          if params[:charity_id].present?
            unless params[:charity_id].to_i > 0
              raise ActiveRecord::RecordNotFound
            end
            unless charity = Charity.find(params[:charity_id].to_i)
              raise ActiveRecord::RecordNotFound
            end
            charity.causes.destroy(@cause)
          else
            @cause.recursively_destroy!
            respond_to do |format|
              format.html { redirect_to api_causes_url, notice: 'Cause was successfully destroyed.' }
              format.json { head :no_content }
            end
          end
        end
      end

      private

      # Never trust parameters from the scary internet, only allow the white list through.
      def cause_params
        params.require(:cause).permit(:name, :parent_id, :description)
      end
    end
  end
end
