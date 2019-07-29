class AttendanceContactsController < ApplicationController

  load_and_authorize_resource

  def index

    @attendance_contacts = @attendance_contacts.includes({attendance: [:time_slot]}, :contact)

    respond_to do |format|
      format.csv do
        response.headers['Content-Type'] = 'text/csv'
        response.headers['Content-Disposition'] = 'attachment; filename="attendance_detail.csv"'
      end
    end
  end
end
