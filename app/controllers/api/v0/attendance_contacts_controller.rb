class Api::V0::AttendanceContactsController < Api::V0::ApiController
  respond_to :json

  authorize_resource

  def create
    # params[:contact_id]
    # params[:time_slot_id]
    # params[:attendance_on]
    @time_slot = TimeSlot.find(params[:time_slot_id])
    @contact = Contact.get_by_padma_id(params[:contact_id], @time_slot.account_id)
    @attendance_on = Date.parse(params[:attendance_on])

    if @time_slot && @contact && @attendance_on

      unless (@attendance = Attendance.where(time_slot_id: @time_slot.id, attendance_on: @attendance_on).first)
        @attendance = Attendance.create!(
          time_slot_id: @time_slot.id,
          attendance_on: @attendance_on,
          username: @time_slot.padma_uid,
          account_id: @time_slot.account_id
        )
      end

      unless (@attendance_contact = AttendanceContact.where(attendance_id: @attendance.id, contact_id: @contact.id).first)
        @attendance_contact = AttendanceContact.create!(
          attendance_id: @attendance.id,
          contact_id: @contact.id,
          source: "api"
        )
      end

      render json: @attendance_contact.to_json, status: 201
    else
      render json: "error", code: 400
    end

  end

  def destroy
    @attendance_contact = AttendanceContact.find(params[:id])
    @attendance_contact.destroy
    render json: "ok"
  end

end

