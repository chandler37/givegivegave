module Api
  module V1
    class CharitiesController < ::NonRailsAdminApplicationController
      load_and_authorize_resource

      # GET /api/v1/charities
      # GET /api/v1/charities.json
      def index
        # TODO(chandler37): When a search query is provided, use
        # Charity.search("red cross") (note there's also raw_searcH) from
        # algoliasearch.
      end

      # GET /api/v1/charities/1
      # GET /api/v1/charities/1.json
      def show
      end

      # POST /api/v1/charities
      # POST /api/v1/charities.json
      def create
        respond_to do |format|
          if @charity.save
            format.html { redirect_to(api_charity_url(@charity), notice: 'Charity was successfully created.') }
            format.json { render :show, status: :created, location: api_charity_url(@charity) }
          else
            format.html { render json: @charity.errors, status: :unprocessable_entity } # TODO(chandler37): show proper html for this rare case
            format.json { render json: @charity.errors, status: :unprocessable_entity }
          end
        end
      end

      # PATCH/PUT /api/v1/charities/1
      # PATCH/PUT /api/v1/charities/1.json
      def update
        respond_to do |format|
          if @charity.update(charity_params)
            format.html { redirect_to(api_charity_url(@charity), notice: 'Charity was successfully updated.') }
            format.json { render :show, status: :ok, location: api_charity_url(@charity) }
          else
            format.html { render json: @charity.errors, status: :unprocessable_entity } # TODO(chandler37): show proper html for this rare case
            format.json { render json: @charity.errors, status: :unprocessable_entity }
          end
        end
      end

      # DELETE /api/v1/charities/1
      # DELETE /api/v1/charities/1.json
      def destroy
        @charity.destroy
        respond_to do |format|
          format.html { redirect_to api_charities_url, notice: 'Charity was successfully destroyed.' }
          format.json { head :no_content }
        end
      end

      private

      # Never trust parameters from the scary internet, only allow the white list through.
      def charity_params
        params.require(:charity).permit(:name, :ein, :description, :score_overall, :stars_overall, :website)
      end
    end
  end
end
