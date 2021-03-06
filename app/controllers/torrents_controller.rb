# Torrents Controller
class TorrentsController < ApplicationController
  decorates_assigned :torrent

  # GET /torrents/:id/download
  def download
    file_path = TorrentDownload.new.call(
      torrent: current_user.torrents.find(params[:id])
    )
    send_file(file_path)
  end

  # POST /torrents
  def create
    TorrentCreation.new.call(user: current_user, file: torrent_params[:file])
    render status: 201, json: { message: I18n.t('torrents.file_added') }
  rescue InvalidFileError => e
    render status: 400, json: { message: I18n.t(e.message) }
  rescue TorrentCreationError => e
    render status: 403, json: { message: I18n.t(e.message) }
  rescue ActiveRecord::RecordInvalid => e
    logger.warn e.message
    render status: 422, json: { message: I18n.t('torrents.duplicate_file') }
  rescue ApplicationError
    render status: 500, json: { message: I18n.t('torrents.service_stopped') }
  end

  # DELETE /torrents/:id
  def destroy
    torrent = current_user.torrents.find(params[:id])
    torrent.destroy!
    flash[:success] = I18n.t('torrents.deleted')
    redirect_to :dashboard
  end

  private

  def torrent_params
    params.require(:torrent).permit(:file)
  end
end
