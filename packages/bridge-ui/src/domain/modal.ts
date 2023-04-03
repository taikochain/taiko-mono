export type NoticeOpenArgs = {
  name?: string;
  title?: string;
  onConfirm?: (informed: boolean) => void;
};

export type NoticeModalOpen = (args: NoticeOpenArgs) => void;
