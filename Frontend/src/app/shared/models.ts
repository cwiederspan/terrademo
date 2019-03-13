export interface Resource {

    filename: string;
    author: string;
    title: string;
    description: string;
    content: string;
    tags: string[];
}

export interface ResourceRequest {

    files: string[];
}