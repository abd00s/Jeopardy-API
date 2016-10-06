class Api::QuestionsController < ApiController
  def show
    @question =
      begin
        Question.find(question_params[:id])
      rescue ActiveRecord::RecordNotFound
        display_error("There is no question with ID #{question_params[:id]}") and return
      end
    respond_with @question, serializer: QuestionOnlySerializer, root: :question
  end

  def random
    # Returns a random question, asked between two dates, if provided.
    # Example usage:
    # ../questions/random.json?newer_than=2009-03-02&older_than=2010-02-03
    # Optional parameters `newer_than` and `older_than` define bounds if present
    # Query string may include an upper and/or a lower bound or none.

    if params[:newer_than].present?
      minimum =
        begin
          Date.parse(params[:newer_than])
        rescue ArgumentError, TypeError
          display_error("Invalid lower bound, format should be YYYY-DD-MM") and return
        end
    end

    if params[:older_than].present?
      maximum =
        begin
          Date.parse(params[:older_than])
        rescue ArgumentError, TypeError
          display_error("Invalid upper bound, format should be YYYY-DD-MM") and return
        end
    end

    if minimum.present? && maximum.present? && minimum > maximum
      display_error("Invalid range; minimum is greater than maximum.") and return
    end

    # We make use of chaining scopes defined on Question.
    @question = Question.newer_than(minimum)
      .older_than(maximum)
      .random

    if @question.present?
      respond_with @question, serializer: QuestionOnlySerializer, root: :question
    else
      oldest = Show.order(:air_date).first.air_date
      newest = Show.order(air_date: :desc).first.air_date
      display_error("No questions in selected range; no shows aired in range or" \
        + "bounds are outside of valid range #{oldest} to #{newest}") and return
    end
  end

  private
    def question_params
      params.permit(:id)
    end
end
