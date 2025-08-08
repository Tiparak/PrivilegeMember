import { useEffect, useState } from "react";
import { supabase, supabaseConfig } from "@/lib/supabase";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { CheckCircle, XCircle, AlertCircle } from "lucide-react";

export function SupabaseStatus() {
  const [connectionStatus, setConnectionStatus] = useState<
    "checking" | "connected" | "error"
  >("checking");
  const [error, setError] = useState<string>("");

  useEffect(() => {
    const checkConnection = async () => {
      try {
        // Try to get the current session
        const { data, error } = await supabase.auth.getSession();

        if (error) {
          setConnectionStatus("error");
          setError(error.message);
        } else {
          setConnectionStatus("connected");
        }
      } catch (err: any) {
        setConnectionStatus("error");
        setError(err.message || "Unknown connection error");
      }
    };

    if (supabaseConfig.isConfigured) {
      checkConnection();
    } else {
      setConnectionStatus("error");
      setError("Supabase not properly configured");
    }
  }, []);

  const getStatusIcon = () => {
    switch (connectionStatus) {
      case "connected":
        return <CheckCircle className="w-5 h-5 text-green-500" />;
      case "error":
        return <XCircle className="w-5 h-5 text-red-500" />;
      default:
        return <AlertCircle className="w-5 h-5 text-yellow-500" />;
    }
  };

  const getStatusBadge = () => {
    switch (connectionStatus) {
      case "connected":
        return (
          <Badge variant="default" className="bg-green-500">
            Connected
          </Badge>
        );
      case "error":
        return <Badge variant="destructive">Error</Badge>;
      default:
        return <Badge variant="secondary">Checking...</Badge>;
    }
  };

  // Only show in development mode
  if (true) { // Always hide the status component
    return null;
  }

  return (
    <Card className="mb-4 border-yellow-200 bg-yellow-50">
      <CardHeader className="pb-3">
        <div className="flex items-center justify-between">
          <CardTitle className="text-lg flex items-center">
            {getStatusIcon()}
            <span className="ml-2">Supabase Connection Status</span>
          </CardTitle>
          {getStatusBadge()}
        </div>
        <CardDescription>
          Development mode - Database connection status
        </CardDescription>
      </CardHeader>
      <CardContent>
        <div className="space-y-2 text-sm">
          <div className="flex justify-between">
            <span>URL:</span>
            <span className="font-mono text-xs">{supabaseConfig.url}</span>
          </div>
          <div className="flex justify-between">
            <span>Has API Key:</span>
            <span
              className={
                supabaseConfig.hasKey ? "text-green-600" : "text-red-600"
              }
            >
              {supabaseConfig.hasKey ? "Yes" : "No"}
            </span>
          </div>
          <div className="flex justify-between">
            <span>Configured:</span>
            <span
              className={
                supabaseConfig.isConfigured ? "text-green-600" : "text-red-600"
              }
            >
              {supabaseConfig.isConfigured ? "Yes" : "No"}
            </span>
          </div>
          {error && (
            <div className="mt-3 p-2 bg-red-100 border border-red-300 rounded text-red-700">
              <strong>Error:</strong> {error}
            </div>
          )}
          {!supabaseConfig.isConfigured && (
            <div className="mt-3 p-2 bg-blue-100 border border-blue-300 rounded text-blue-700">
              <strong>Setup Required:</strong> Please configure your Supabase
              environment variables.
            </div>
          )}
        </div>
      </CardContent>
    </Card>
  );
}
