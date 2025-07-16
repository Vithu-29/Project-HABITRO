import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { cn } from "@/lib/utils";
import Image from "next/image";
import { getRecentUsersData } from "@/services/table.services"; 

export async function RecentUsers({ className }: { className?: string }) {
  const users = await getRecentUsersData(); 

  return (
    <div
      className={cn(
        "w-full max-w-9xl min-h-[450px] rounded-lg bg-white px-5 pb-3 pt-5 shadow-md dark:bg-gray-dark dark:shadow-lg",
        className
      )}
    >
      <h2 className="mb-3 text-lg font-semibold text-dark dark:text-white">
        Recent Users
      </h2>

      <div className="overflow-x-auto">
        <Table className="w-full">
          <TableHeader>
            <TableRow className="border-none uppercase [&>th]:text-center text-sm">
              <TableHead className="min-w-[150px] !text-left px-3">Name</TableHead>
              <TableHead className="px-3">Email</TableHead>
              <TableHead className="!text-right px-3">Joined</TableHead>
              <TableHead className="px-3">Added Habit</TableHead>
            </TableRow>
          </TableHeader>

          <TableBody>
            {users.map((user: any, i: number) => (
              <TableRow
                className="h-10 text-center text-sm font-medium text-dark dark:text-white "
                key={user.email + i}
              >
                <TableCell className="flex items-center gap-2 p-4 text-left">
                  <Image
                    src={user.avatar}
                    className="size-6 rounded-full object-cover"
                    width={32}
                    height={32}
                    alt={user.name + " avatar"}
                    role="presentation"
                  />
                  <div className="text-sm">{user.name}</div>
                </TableCell>

                <TableCell className="p-2">{user.email}</TableCell>

                <TableCell className="!text-right p-2 text-green-light-1">
                  {user.joined}
                </TableCell>

                <TableCell className="p-2">{user.habit}</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
    </div>
  );
}
