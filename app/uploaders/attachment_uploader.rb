class AttachmentUploader < CarrierWave::Uploader::Base
  IMAGE_EXTENSIONS = %w(jpeg jpg png tiff).freeze
  ARCHIVE_EXTENSIONS = %w(rar gz 7z).freeze
  DOCUMENT_EXTENSIONS = %w(pdf rtf psd).freeze
  MS_OFFICE_EXTENSIONS = %w(doc docx xls xlsx xlsb pub one).freeze
  OPEN_OFFICE_EXTENSIONS = %w(odt ott sxw stw sdw).freeze
  APPLE_OFFICE_EXTENSIONS = %w(key numbers pages).freeze

  SUPPORTED_FILE_EXTENSIONS = [
    IMAGE_EXTENSIONS +
    ARCHIVE_EXTENSIONS +
    DOCUMENT_EXTENSIONS +
    MS_OFFICE_EXTENSIONS +
    OPEN_OFFICE_EXTENSIONS +
    APPLE_OFFICE_EXTENSIONS
  ].flatten.freeze

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_white_list
    SUPPORTED_FILE_EXTENSIONS
  end
end
