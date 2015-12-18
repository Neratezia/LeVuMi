# -*- encoding : utf-8 -*-

require 'spreadsheet'

class Test < ActiveRecord::Base
  has_many :items, :dependent => :destroy
  has_many :assessments, :dependent => :destroy

  validates_presence_of :name
  validates_presence_of :subject
  validates_presence_of :category

  def draw_items(ability)
    itemset = Array.new
    (1..len).each  do
      remaining = items - itemset
      itemset = itemset + [remaining.sample]
    end
    return itemset.map{|i| i.id}
  end

  def len_info
    return "#{len} Items"
  end

  def type_info
    return "Test"
  end

  def view_info
    return "Test"
  end

  def export
    measurements = Measurement.where(:assessment => Assessment.where(:test => self))
    results = Result.where(:measurement => measurements)
    students = Student.where(:id => results.uniq.pluck(:student_id))

    book = Spreadsheet::Workbook.new

    sheet = book.create_worksheet :name => 'Items'
    sheet.row(0).concat Item.xls_headings
    i = 1
    items.each do |it|
      sheet.row(i).concat it.to_a
      i = i+1
    end

    sheet = book.create_worksheet :name => 'SuS'
    sheet.row(0).concat Student.xls_headings
    i = 1
    students.find_each do |s|
      sheet.row(i).concat s.to_a
      i = i+1
    end

    sheet = book.create_worksheet :name => "Alle Messungen"
    sheet.row(0).concat %w(Schüler/in Messzeitpunkt Tester)
    itemset = items.pluck(:id)
    sheet.row(0).concat itemset
    i = 1
    results.find_each do |r|
      sheet.row(i).push r.student.id
      sheet.row(i).push r.measurement.date.to_date.strftime("%d.%m.%Y")
      sheet.row(i).push r.measurement.assessment.group.user.id
      sheet.row(i).concat r.to_a(itemset)
      i = i+1
    end

    measurements.sort_by { |a| a.date}.each do |m|
      sheet = book.create_worksheet :name => "Messung #{m.id}"
      sheet.row(0).push "Datum"
      sheet.row(0).push m.date.to_date.strftime("%d.%m.%Y")
      sheet.row(1).push "Tester"
      sheet.row(1).push m.assessment.group.user.id

      sheet.row(2).concat %w(Student)
      itemset = items.pluck(:id)
      sheet.row(2).concat itemset
      i = 3
      m.results.each do |r|
        sheet.row(i).push r.student.id
        sheet.row(i).concat r.to_a(itemset)
        i = i+1
      end
    end

    temp = Tempfile.new("LeVuMi")
    temp.close
    book.write temp.path
    return temp.path
  end
end
