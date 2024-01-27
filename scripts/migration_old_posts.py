import os
import re
import shutil


def copy_image_file(src_dir, dest_dir, image_path):
    """이미지 파일을 복사하는 함수"""
    src_image_path = os.path.join(src_dir, image_path)
    dest_image_path = os.path.join(dest_dir, image_path)

    if os.path.exists(src_image_path):
        if os.path.exists(dest_image_path):
            return

        print("파일 OK", src_image_path)
        # 필요한 경우, 목적지 폴더 생성
        os.makedirs(os.path.dirname(dest_image_path), exist_ok=True)
        shutil.copy(src_image_path, dest_image_path)
    else:
        print("파일이 존재하지 않습니다. ", src_image_path)


def copy_hugo_metadata_image(line, images_src_dir, images_dest_dir, new_file_name):
    pattern = r"images:\s*\[(\/images\/.+?)\]"
    match = re.match(pattern, line)
    if match:
        print(line)
        image_path = match.group(1)
        if image_path.startswith("/images"):
            basename = re.sub(r"^\/images/", "", image_path)
            _, file_extension = os.path.splitext(basename)
            new_filename = f"{new_file_name}{file_extension}"
            copy_image_file(images_src_dir, images_dest_dir, basename)
            return f'image: "/images/posts/{basename}"\n'
    return line


def replace_image_syntax(line, images_src_dir, current_dest_folder):
    """이미지 구문을 Markdown 형식으로 변환하고 필요한 경우 이미지 복사"""
    pattern = r'{{<\s*image src="([^\s]*?)".*>}}'

    def replace(match):
        image_path = match.group(1)
        return f"![]({image_path})"

    return re.sub(pattern, replace, line)


def copy_markdown_image_file(line, images_src_dir, current_dest_folder):
    pattern = r"!\[\]\(([^\s]*?)\)"
    match = re.match(pattern, line)
    if match:
        image_path = match.group(1)
        if image_path.startswith("/images"):
            basename = re.sub(r"^\/images/", "", image_path)
            copy_image_file(images_src_dir, current_dest_folder, basename)
            return f"![]({basename})"
    return line


def process_markdown_file(
    src_file, dest_file, images_src_dir, images_dest_dir, current_dest_folder
):
    """Markdown 파일 처리 및 복사, 이미지 파일도 함께 복사"""
    with open(src_file, "r") as src, open(dest_file, "w") as dest:
        for line in src:
            rl1 = copy_hugo_metadata_image(
                line, images_src_dir, images_dest_dir, current_dest_folder
            )
            rl2 = replace_image_syntax(rl1, images_src_dir, current_dest_folder)
            rl3 = copy_markdown_image_file(rl2, images_src_dir, current_dest_folder)
            dest.write(rl3)


def copy_and_transform_markdown(
    src_dir, dest_dir, images_src_dir, images_dest_dir, log_file
):
    # 로그 파일 준비
    with open(log_file, "w") as log:
        # .md 또는 .markdown 파일 탐색 및 처리
        for root, dirs, files in os.walk(src_dir):
            for file in files:
                if file.endswith((".md", ".markdown")):
                    # 파일의 전체 경로
                    full_file_path = os.path.join(root, file)

                    # 목적지 폴더 경로 생성 (파일 이름을 폴더 이름으로 사용)
                    file_name_without_ext = os.path.splitext(file)[0]
                    dest_folder_path = os.path.join(dest_dir, file_name_without_ext)

                    # 목적지 폴더가 없으면 생성
                    if not os.path.exists(dest_folder_path):
                        os.makedirs(dest_folder_path)

                    # index.md 파일 경로 설정
                    dest_file_path = os.path.join(dest_folder_path, "index.md")
                    # index_count = 2

                    # # 이미 파일이 존재하면 index2.md, index3.md 등으로 변경
                    # while os.path.exists(dest_file_path):
                    #     dest_file_path = os.path.join(dest_folder_path, f'index{index_count}.md')
                    #     index_count += 1

                    # 파일 처리 및 복사
                    process_markdown_file(
                        full_file_path,
                        dest_file_path,
                        images_src_dir,
                        images_dest_dir,
                        dest_folder_path,
                    )

                    # 로그 기록
                    log.write(
                        f"Copied and transformed '{full_file_path}' to '{dest_file_path}'\n"
                    )


# 사용할 변수들 정의
source_directory = "/Users/ewcho/Source/my-blog/content/posts"
destination_directory = "/Users/ewcho/Source/my-hugo-blog/content/posts"
images_source_directory = "/Users/ewcho/Source/my-blog/static/images"
images_destination_directory = "/Users/ewcho/Source/my-hugo-blog/assets/images/posts"
log_file_path = "/Users/ewcho/Source/my-blog/copy_log.txt"


copy_and_transform_markdown(
    source_directory,
    destination_directory,
    images_source_directory,
    images_destination_directory,
    log_file_path,
)
