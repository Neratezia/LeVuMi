# -*- encoding : utf-8 -*-
class TestsController < ApplicationController
  before_action :set_test, only: [:show, :edit, :update, :destroy]
  before_filter :is_allowed, only: [:edit, :update, :destroy, :new]

  # GET /tests
  def index
    @tests = Test.all
  end

  # GET /tests/1/edit
  def edit
  end

  # DELETE /tests/1
  # DELETE /tests/1.json
  def destroy
    @test.destroy
    respond_to do |format|
      format.html { redirect_to tests_url, notice: 'Test wurde gelöscht.' }
    end
  end

  # PATCH/PUT /tests/1
  # PATCH/PUT /tests/1.json
  def update
    respond_to do |format|
      if @test.update(test_params)
        format.js
      else
        format.js { render :edit }
      end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_test
    @test = Test.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def test_params
    params.require(:test).permit(:name, :info, :shortinfo, :subject, :category)
  end

  def is_allowed
    unless @login.hasCapability?("test")
      redirect_to root_url
      return false
    end
    return true
  end
end
